# MASTER IMPLEMENTATION PLAN: HỆ THỐNG THI TOEIC READING (FLUTTER + ASP.NET CORE + MS SQL SERVER)

> **Tài liệu dành cho AI Coding Agent:** Tài liệu này là bản đặc tả kỹ thuật toàn diện (System Prompt / Specification) kết hợp đầy đủ yêu cầu từ `Đề thi giữa kỳ v2.pdf`, `EnglishTest.pdf` (Test 1: Câu 101-130) và `Reading v09.pdf` (ETS Test 09: Câu 101-200). Coding Agent cần tuân thủ tuyệt đối kiến trúc thư mục, thiết kế CSDL, quy tắc đọc file Word (`.docx`) và **đặc biệt là 2 quy tắc nghiệp vụ ưu tiên từ người dùng**:
>
> 1. **KHÔNG CẦN ĐĂNG KÝ / ĐĂNG NHẬP (No-Auth):** Mở ứng dụng Flutter lên là vào thẳng danh sách đề thi và bắt đầu làm bài ngay lập tức.
> 2. **NỘP BÀI SỚM (Early Submission 1-2 câu):** Không bắt buộc làm hết đề. Khi người dùng bắt đầu làm bài, **chỉ cần chọn tối thiểu 1 - 2 câu là đã có thể bấm "Nộp bài"** để hệ thống chấm điểm, thống kê câu đúng/sai/bỏ qua ngay lập tức.

---

## 1. TỔNG QUAN KIẾN TRÚC & CẤU TRÚC THƯ MỤC

Dự án được đặt trong thư mục gốc `GiuaKy` với 2 thành phần chính theo đúng yêu cầu đề bài:

```text
GiuaKy/
├── backend/                  # ASP.NET Core MVC + Web API (dựa trên ASP.NET Boilerplate / EF Core)
│   ├── src/
│   │   ├── GiuaKy.Core/              # Entities, Domain Models, Constants
│   │   ├── GiuaKy.EntityFrameworkCore/ # DbContext, Migrations (Microsoft SQL Server)
│   │   ├── GiuaKy.Application/       # Services: DocxParser, ExamAppService, AttemptAppService
│   │   └── GiuaKy.Web.Mvc/           # Giao diện Web cho Giảng viên + RESTful API cho Flutter
├── frontend/                 # Ứng dụng Mobile viết bằng Flutter dành cho Người học
│   ├── lib/
│   │   ├── core/             # Config API, Theme, Constants, Utils
│   │   ├── data/             # Models, API Services (Dio/Http)
│   │   ├── providers/        # State Management (Riverpod hoặc Provider/BLoC)
│   │   └── ui/               # Screens & Widgets (ExamListScreen, ExamRoomScreen, ExamResultScreen)
│   └── pubspec.yaml
└── sample_exams/             # Chứa các file Word (.docx) chuẩn hóa đã gắn Tags
    ├── EnglishTest_Part5_Full_Tagged.docx
    └── ETS_Reading_Test09_Full_Tagged.docx
```

* **Database:** Microsoft SQL Server.
* **Backend:** ASP.NET Core MVC kết hợp REST API (sử dụng thư viện `DocumentFormat.OpenXml` để đọc file `.docx`). Giao diện Web của Giảng viên và API cho Mobile được mở công khai (`[AllowAnonymous]`) để không yêu cầu đăng nhập.
* **Frontend Mobile:** Flutter (Android/iOS), giao diện hiện đại, trực quan, vào thẳng màn hình chọn đề và thi ngay.

---

## 2. ĐẶC TẢ BỘ THẺ (TAGS) CHO FILE WORD (`.docx`)

Để hệ thống Backend đọc hiểu được cấu trúc phân cấp của đề thi TOEIC Reading (Level 1 - Part 5: câu hỏi độc lập; Level 2 - Part 6 & Part 7: câu hỏi nhóm theo đoạn văn/hình ảnh), file `.docx` bắt buộc sử dụng bộ thẻ chuẩn sau:

### 2.1. Danh sách các thẻ (Tags) bắt buộc

| Thẻ (Tag) | Ý nghĩa | Quy tắc áp dụng |
| :--- | :--- | :--- |
| `[EXAM_TITLE: <Tên đề>]` | Tên đề thi | Đặt ở đầu file Word. |
| `[EXAM_DURATION: 75]` | Thời gian thi (phút) | Mặc định là `75`. |
| `[PART: <5\|6\|7>]` | Bắt đầu phần thi | Khai báo đầu mỗi Part (Part 5, Part 6, Part 7). |
| `[PASSAGE_START]` ... `[PASSAGE_END]` | Khối nội dung bài đọc | Dùng cho **Part 6 & Part 7** (chứa văn bản, bảng biểu hoặc hình ảnh đính kèm). Không dùng cho Part 5. |
| `[SHUFFLE_Q: <TRUE\|FALSE>]` | Tag cho phép hoán vị câu hỏi | Đặt đầu mỗi câu hỏi hoặc trong khối Passage. |
| `[Q: <Số thứ tự>]` | Bắt đầu một câu hỏi và nội dung câu hỏi | Ví dụ: `[Q: 101]` (Từ 101 đến 200). |
| `[SHUFFLE_A: <TRUE\|FALSE>]` | Tag cho phép hoán vị đáp án | Đặt ngay dưới dòng `[Q: ...]`. |
| `[A]`, `[B]`, `[C]`, `[D]` | Nội dung 4 phương án trả lời | Bắt buộc đủ 4 phương án cho mỗi câu. |
| `[ANS: <A\|B\|C\|D>]` | Đáp án đúng | Chỉ nhận 1 giá trị trong `A`, `B`, `C`, `D`. |
| `[HINT: <Nội dung gợi ý>]` | Gợi ý / Giải thích đáp án | Hiển thị khi xem trước hoặc sau khi nộp bài. |
| `[Q_END]` | Kết thúc 1 câu hỏi | Đóng block câu hỏi để tránh lẫn dòng. |

---

## 3. DỮ LIỆU ĐỀ THI CHUẨN HÓA TỪ `EnglishTest.pdf` & `Reading v09.pdf`

Coding Agent sử dụng toàn bộ dữ liệu đã được trích xuất, giải đáp án và viết gợi ý dưới đây để tạo sẵn file `.docx` mẫu trong thư mục `sample_exams/` phục vụ kiểm thử chức năng Upload file Word của Giảng viên.

### 3.1. Bộ đề 1: Toàn bộ 30 câu Part 5 từ `EnglishTest.pdf` + Part 6 mẫu từ `Đề thi giữa kỳ v2.pdf`

```text
[EXAM_TITLE: TOEIC Reading Test 01 - EnglishTest Official]
[EXAM_DURATION: 75]

[PART: 5]

[Q: 101] Ms. Durkin asked for volunteers to help ------- with the employee fitness program.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] she
[B] her
[C] hers
[D] herself
[ANS: B]
[HINT: Cần đại từ nhân xưng làm tân ngữ "her" đứng sau động từ "help" (giúp đỡ cô ấy).]
[Q_END]

[Q: 102] Lasner Electronics' staff have extensive ------- of current hardware systems.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] know
[B] known
[C] knowledge
[D] knowledgeable
[ANS: C]
[HINT: Sau tính từ "extensive" và trước giới từ "of" cần một danh từ: "knowledge" (kiến thức sâu rộng).]
[Q_END]

[Q: 103] ------- a year, Tarrin Industrial Supply audits the accounts of all of its factories.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] Once
[B] Immediately
[C] Directly
[D] Yet
[ANS: A]
[HINT: Cụm chỉ tần suất "Once a year" có nghĩa là mỗi năm một lần.]
[Q_END]

[Q: 104] Ms. Pham requested a refund ------- the coffeemaker she received was damaged.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] despite
[B] why
[C] concerning
[D] because
[ANS: D]
[HINT: Cần liên từ chỉ nguyên nhân "because" đứng trước mệnh đề "the coffeemaker she received was damaged".]
[Q_END]

[Q: 105] Information ------- the artwork in the lobby is available at the reception desk.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] across
[B] about
[C] upon
[D] except
[ANS: B]
[HINT: Cụm "Information about something" mang nghĩa thông tin về cái gì đó.]
[Q_END]

[Q: 106] With the Gema XTI binoculars, users can ------- see objects that are more than 100 meters away.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] ease
[B] easy
[C] easily
[D] easier
[ANS: C]
[HINT: Cần trạng từ "easily" đứng giữa động từ khuyết thiếu "can" và động từ thường "see" để bổ nghĩa cho hành động nhìn.]
[Q_END]

[Q: 107] The Physical Therapy Association is committed to keeping costs ------- for its certification programs.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] affordable
[B] permitted
[C] cutting
[D] necessary
[ANS: A]
[HINT: Cấu trúc "keep + O + Adj" -> "keeping costs affordable" (giữ chi phí ở mức hợp lý/phải chăng).]
[Q_END]

[Q: 108] Mr. Brennel ------- positions in various areas of the company before he became president.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] occupation
[B] occupational
[C] occupying
[D] occupied
[ANS: D]
[HINT: Câu thiếu động từ chính chia ở thì quá khứ đơn ("occupied" - đã nắm giữ các vị trí) trước mệnh đề trạng ngữ chỉ thời gian "before he became president".]
[Q_END]

[Q: 109] To remain on schedule, editors must submit all ------- to the book to the authors by Friday.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] ideas
[B] essays
[C] revisions
[D] suggestions
[ANS: C]
[HINT: "Revisions to the book" có nghĩa là các nội dung chỉnh sửa/sửa đổi đối với cuốn sách.]
[Q_END]

[Q: 110] ------- industry professionals are allowed to purchase tickets to the Kuo Photography Fair.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] Only
[B] Until
[C] Unless
[D] Quite
[ANS: A]
[HINT: Trạng từ "Only" đứng đầu câu bổ nghĩa cho chủ ngữ: "Chỉ những chuyên gia trong ngành mới được phép mua vé...".]
[Q_END]

[Q: 111] At Pharmbeck's banquet, Mr. Jones ------- a trophy for his performance in this year's quality-improvement initiative.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] accepted
[B] congratulated
[C] nominated
[D] hoped
[ANS: A]
[HINT: "Accepted a trophy" có nghĩa là đã đón nhận chiếc cúp khen thưởng.]
[Q_END]

[Q: 112] Ms. Suto claims that important market trends become ------- with the use of data analysis.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] predict
[B] prediction
[C] predictable
[D] predictably
[ANS: C]
[HINT: Sau động từ nối "become" cần một tính từ: "predictable" (có thể dự đoán được).]
[Q_END]

[Q: 113] One of Grommer Consulting's goals is to enhance the relationship ------- salespeople and their customers.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] inside
[B] within
[C] around
[D] between
[ANS: D]
[HINT: Cấu trúc "relationship between A and B" (mối quan hệ giữa nhân viên bán hàng và khách hàng của họ).]
[Q_END]

[Q: 114] Depending on your answers to the survey, we ------- you to collect additional information.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] may call
[B] are calling
[C] have been called
[D) must be calling
[ANS: A]
[HINT: "may call" diễn tả một khả năng có thể xảy ra trong tương lai tùy thuộc vào kết quả khảo sát.]
[Q_END]

[Q: 115] ------- Jemburger opened its newest franchise, the first 100 customers were given free hamburgers.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] Now
[B] When
[C] As if
[D] After all
[ANS: B]
[HINT: Cần liên từ chỉ thời gian "When" nối hai mệnh đề quá khứ đơn (Khi Jemburger mở cửa hàng nhượng quyền mới nhất...).]
[Q_END]

[Q: 116] Please include the serial number of your product in any ------- with the customer service department.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] corresponds
[B] correspondence
[C] correspondingly
[D] correspondent
[ANS: B]
[HINT: Sau lượng từ "any" cần danh từ "correspondence" (thư từ/liên lạc giao dịch với bộ phận CSKH).]
[Q_END]

[Q: 117] The award-winning film Underwater Secrets promotes awareness ------- ocean pollution and its effects on our planet.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] of
[B] to
[C] from
[D] with
[ANS: A]
[HINT: Cụm cố định "promote awareness of something" (nâng cao nhận thức về vấn đề gì).]
[Q_END]

[Q: 118] BYF Company specializes in ------- promotional items to help companies advertise their brand.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] personally
[B] personalized
[C] personality
[D] personalizes
[ANS: B]
[HINT: Cần tính từ "personalized" (được cá nhân hóa) đứng trước bổ nghĩa cho cụm danh từ "promotional items".]
[Q_END]

[Q: 119] ------- the rent increase is less than 2 percent, Selwin Electrical Supply will continue to lease the space.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] As long as
[B] Along with
[C] Not only
[D] Otherwise
[ANS: A]
[HINT: Liên từ điều kiện "As long as" mang nghĩa "Miễn là" (Miễn là mức tăng tiền thuê dưới 2%...).]
[Q_END]

[Q: 120] Belden Hospital's chief of staff meets regularly with the staff to ensure that procedures ------- correctly.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] to be performed
[B] would have performed
[C] had been performed
[D] are being performed
[ANS: D]
[HINT: Mệnh đề sau "that" cần động từ chia ở thể bị động hiện tại "are being performed" để hòa hợp về thì với "meets regularly".]
[Q_END]

[Q: 121] Any requests for time off should be addressed to the ------- department supervisor.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] urgent
[B] appropriate
[C] subsequent
[D] deliverable
[ANS: B]
[HINT: "the appropriate department supervisor" nghĩa là người giám sát bộ phận phù hợp/tương ứng.]
[Q_END]

[Q: 122] World Fish Supply delivers the freshest fish possible thanks to innovative ------- and shipping methods.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] preserves
[B] preserved
[C] preserve
[D] preservation
[ANS: D]
[HINT: Cần danh từ "preservation" (sự bảo quản) song hành với "shipping" để tạo cụm "preservation and shipping methods".]
[Q_END]

[Q: 123] Company executives are currently reviewing the annual budget ------- submitted to them by the Financial Planning department.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] requirements
[B] deliveries
[C] developers
[D] qualities
[ANS: A]
[HINT: "annual budget requirements" có nghĩa là các yêu cầu/đề xuất ngân sách hàng năm.]
[Q_END]

[Q: 124] Even the CEO had to admit that Prasma Designs' win was ------- the result of fortunate timing.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] parts
[B] parted
[C] partly
[D] parting
[ANS: C]
[HINT: Trạng từ "partly" (một phần) bổ nghĩa cho cụm "the result of fortunate timing".]
[Q_END]

[Q: 125] Mr. Singh took notes on ------- the focus group discussed during the morning session.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] each
[B] several
[C] another
[D] everything
[ANS: D]
[HINT: Đại từ "everything" đóng vai trò tân ngữ của giới từ "on" và được bổ nghĩa bởi mệnh đề "the focus group discussed" (mọi thứ mà nhóm đã thảo luận).]
[Q_END]

[Q: 126] Last year, Tadaka Computer Solutions ranked third ------- in regional earnings.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] together
[B] overall
[C] consecutively
[D] generally
[ANS: B]
[HINT: Cụm "ranked third overall" có nghĩa là xếp hạng ba tính trên tổng thể.]
[Q_END]

[Q: 127] ------- the popularity of the BPT39 wireless speaker, production will be increased fivefold starting next month.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] On behalf of
[B] Whether
[C] Moreover
[D] As a result of
[ANS: D]
[HINT: Cụm giới từ chỉ nguyên nhân "As a result of + Noun phrase" (Do kết quả của sự phổ biến...).]
[Q_END]

[Q: 128] Zypo Properties has just signed a lease agreement with the law firm ------- offices are on the third floor.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] how
[B] what
[C] whose
[D] wherever
[ANS: C]
[HINT: Đại từ quan hệ sở hữu "whose" đứng trước danh từ "offices" (công ty luật mà văn phòng của họ ở tầng 3).]
[Q_END]

[Q: 129] ------- events this year caused profits in the second and third quarters to differ significantly from original projections.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] Total
[B] Marginal
[C] Representative
[D] Unforeseen
[ANS: D]
[HINT: Tính từ "Unforeseen" (không lường trước được) bổ nghĩa cho "events" giải thích lý do lợi nhuận khác biệt lớn so với dự kiến.]
[Q_END]

[Q: 130] The timeline for the pathway lighting project was extended to ------- input from the environmental commission.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] use up
[B] believe in
[C] make into
[D] allow for
[ANS: D]
[HINT: Cụm động từ "allow for" mang nghĩa tính đến / cho phép có thêm thời gian để tiếp nhận ý kiến đóng góp.]
[Q_END]

[PART: 6]
[PASSAGE_START]
Questions 131-134 refer to the following advertisement.
With Global Strength Gym's 30-day trial period, you get the opportunity to try out our classes, equipment, and facilities. It's completely risk-free! To sign up, we require your contact information and payment details, but you will only be charged if you are a member for ---[132]--- 30 days. ---[131]---. If you decide within this time that you no longer want to be a member of Global Strength, visit our Web site at www.gsgym.com. On the Membership page, elect to ---[134]--- your membership and ---[133]--- enter the necessary information. It's that easy!
[PASSAGE_END]

[Q: 131] Chọn câu phù hợp điền vào vị trí [131]:
[SHUFFLE_Q: FALSE]
[SHUFFLE_A: TRUE]
[A] Throughout the trial, you pay nothing and sign no contract.
[B] Weight-lifting classes are not currently available.
[C] A cash deposit is required when you sign up for membership.
[D] All questions should be e-mailed to customerservice@gsgym.com.
[ANS: A]
[HINT: Đoạn văn đang nói về gói dùng thử 30 ngày miễn phí rủi ro ("completely risk-free"), nên câu A là phù hợp nhất.]
[Q_END]

[Q: 132] Chọn từ phù hợp điền vào vị trí [132]:
[SHUFFLE_Q: FALSE]
[SHUFFLE_A: TRUE]
[A] not even
[B] almost
[C] over
[D] less than
[ANS: C]
[HINT: Bạn chỉ bị tính phí nếu là thành viên trên 30 ngày ("over 30 days").]
[Q_END]

[Q: 133] Chọn từ phù hợp điền vào vị trí [133]:
[SHUFFLE_Q: FALSE]
[SHUFFLE_A: TRUE]
[A] justly
[B] regularly
[C] evenly
[D] simply
[ANS: D]
[HINT: Trạng từ "simply" (chỉ cần đơn giản là nhập thông tin cần thiết), khớp với câu kết "It's that easy!".]
[Q_END]

[Q: 134] Chọn từ phù hợp điền vào vị trí [134]:
[SHUFFLE_Q: FALSE]
[SHUFFLE_A: TRUE]
[A] extend
[B] renew
[C] cancel
[D] initiate
[ANS: C]
[HINT: Nếu không muốn làm thành viên nữa ("no longer want to be a member"), hãy chọn hủy ("cancel") tư cách thành viên.]
[Q_END]
```

### 3.2. Bộ đề 2: Bảng Đáp án & Cấu trúc của `Reading v09.pdf` (ETS Test 09: Câu 101 - 200)

Để Coding Agent tạo thêm file Word thứ 2 (`ETS_Reading_Test09_Full_Tagged.docx`) đủ cả 3 phần Part 5, Part 6, Part 7:

* **Part 5 (Câu 101 - 130):**
  * `101: B (their)` | `102: B (greatly)` | `103: C (ingredients)` | `104: B (at)` | `105: D (shipping)`
  * `106: C (closely)` | `107: B (when)` | `108: A (attended)` | `109: A (from)` | `110: A (economical)`
  * `111: C (rely)` | `112: B (which)` | `113: C (its)` | `114: B (several)` | `115: C (Since)`
  * `116: A (construction)` | `117: A (executing)` | `118: B (gradually)` | `119: D (between)` | `120: D (few)`
  * `121: A (because of)` | `122: D (effectively)` | `123: D (anytime)` | `124: A (proficiency)` | `125: C (continually)`
  * `126: A (can finish)` | `127: D (except that)` | `128: C (questionable)` | `129: B (assumption)` | `130: D (waives)`
* **Part 6 (Câu 131 - 146, gồm 4 Passages):**
  * Passage 1 (131-134 - Email Joining ASA): `131: C (conference)`, `132: A (can benefit)`, `133: D (This month you can join...)`, `134: B (me)`
  * Passage 2 (135-138 - Email Workshop): `135: B (direct)`, `136: A (will be provided)`, `137: C (Please let us know if you have any dietary restrictions)`, `138: A (useful)`
  * Passage 3 (139-142 - Article Venley Foods): `139: B (Apparently)`, `140: D (The number increases to 20 percent...)`, `141: C (smarter)`, `142: A (value)`
  * Passage 4 (143-146 - Article Nylobe, Inc.): `143: C (financial)`, `144: D (asset)`, `145: A (This will reduce the need...)`, `146: D (Fortunately)`
* **Part 7 (Câu 147 - 200, câu hỏi nhóm bài đọc đơn và đa đoạn văn):**
  * Passage 147-148 (Invoice 3987): `147: B`, `148: D`
  * Passage 149-151 (Harbour View Apartment): `149: D`, `150: B`, `151: A`
  * Passage 152-153 (Text-message chain Salter & Ortiz): `152: D`, `153: C`
  * Passage 154-155 (Email Sardha's Banquet Hall): `154: C`, `155: D`
  * Passage 156-157 (Memo OS Update): `156: B`, `157: D`
  * Passage 158-160 (Letter Clarke-Ellis Construction): `158: A`, `159: C`, `160: B`
  * Passage 161-164 (Ad Goldhorse Press): `161: C`, `162: B`, `163: B`, `164: D`
  * Passage 165-168 (Online chat Derek Boutique): `165: B`, `166: C`, `167: D`, `168: A`
  * Passage 169-171 (Article Dr. Esther Nujoma): `169: D`, `170: A`, `171: B`
  * Passage 172-175 (Notice Ferry Service): `172: A`, `173: D`, `174: B`, `175: C`
  * Passage 176-180 (Green Stripe Press Receipt & Email): `176: B`, `177: D`, `178: D`, `179: A`, `180: B`
  * Passage 181-185 (Hilgrave Historical Commission): `181: D`, `182: B`, `183: D`, `184: C`, `185: A`
  * Passage 186-190 (Anson House Speaker Series): `186: D`, `187: A`, `188: C`, `189: C`, `190: B`
  * Passage 191-195 (CRYN Group & Tayerson Ltd.): `191: D`, `192: A`, `193: B`, `194: D`, `195: C`
  * Passage 196-200 (FGJ's Business Expert Series): `196: B`, `197: B`, `198: D`, `199: D`, `200: C`

---

## 4. THIẾT KẾ CƠ SỞ DỮ LIỆU (MICROSOFT SQL SERVER)

Hệ thống chia làm 6 bảng có quan hệ phân cấp chặt chẽ để xử lý cả câu hỏi độc lập (Part 5) và câu hỏi nhóm theo đoạn văn/hình ảnh (Part 6, 7), đồng thời lưu lịch sử làm bài không cần tài khoản (`ExamAttempts`).

### 4.1. Sơ đồ cấu trúc bảng (SQL DDL)

```sql
-- 1. Bảng Đề thi (Exams)
CREATE TABLE Exams (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255) NOT NULL,
    Description NVARCHAR(500) NULL,
    DurationMinutes INT NOT NULL DEFAULT 75,
    TotalQuestions INT NOT NULL DEFAULT 100,
    IsPublished BIT NOT NULL DEFAULT 0, -- 0: Nháp (Chưa xuất bản), 1: Đã xuất bản (Cho phép thi)
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL
);

-- 2. Bảng Đoạn văn / Nhóm câu hỏi (Passages - Dùng cho Part 6 & Part 7)
CREATE TABLE Passages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ExamId INT NOT NULL,
    PartNumber INT NOT NULL, -- 6 hoặc 7
    ContentHtml NVARCHAR(MAX) NULL, -- Nội dung bài đọc (hỗ trợ định dạng đoạn văn, bảng biểu)
    ImageUrl NVARCHAR(500) NULL,    -- Đường dẫn ảnh nếu đoạn văn có chứa ảnh từ file Word
    OrderIndex INT NOT NULL,
    CONSTRAINT FK_Passages_Exams FOREIGN KEY (ExamId) REFERENCES Exams(Id) ON DELETE CASCADE
);

-- 3. Bảng Câu hỏi (Questions)
CREATE TABLE Questions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ExamId INT NOT NULL,
    PassageId INT NULL, -- NULL đối với Part 5; Có giá trị đối với Part 6 & Part 7
    PartNumber INT NOT NULL, -- 5, 6, hoặc 7
    QuestionNumber INT NOT NULL, -- Số thứ tự câu (VD: 101 -> 200)
    QuestionText NVARCHAR(MAX) NULL, -- Nội dung câu hỏi
    Hint NVARCHAR(MAX) NULL, -- Gợi ý câu trả lời / Giải thích
    AllowShuffleQuestion BIT NOT NULL DEFAULT 0, -- Tag hoán vị câu hỏi
    AllowShuffleOptions BIT NOT NULL DEFAULT 0,  -- Tag hoán vị đáp án trả lời
    CONSTRAINT FK_Questions_Exams FOREIGN KEY (ExamId) REFERENCES Exams(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Questions_Passages FOREIGN KEY (PassageId) REFERENCES Passages(Id)
);

-- 4. Bảng Đáp án lựa chọn (QuestionOptions)
CREATE TABLE QuestionOptions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    QuestionId INT NOT NULL,
    OptionLabel CHAR(1) NOT NULL, -- 'A', 'B', 'C', 'D'
    OptionText NVARCHAR(MAX) NOT NULL,
    IsCorrect BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Options_Questions FOREIGN KEY (QuestionId) REFERENCES Questions(Id) ON DELETE CASCADE
);

-- 5. Bảng Lượt thi (ExamAttempts - KHÔNG CẦN USER ID ĐĂNG NHẬP)
CREATE TABLE ExamAttempts (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ExamId INT NOT NULL,
    DeviceIdentifier NVARCHAR(100) NULL, -- Lưu mã thiết bị tạm hoặc "Khách" (Không cần login)
    StartTime DATETIME2 NOT NULL DEFAULT GETDATE(),
    SubmitTime DATETIME2 NOT NULL DEFAULT GETDATE(),
    DurationSeconds INT NOT NULL DEFAULT 0,
    TotalQuestions INT NOT NULL,
    AnsweredCount INT NOT NULL, -- Có thể chỉ từ 1-2 câu là đã nộp bài
    CorrectCount INT NOT NULL,
    WrongCount INT NOT NULL,
    SkippedCount INT NOT NULL,
    Score DECIMAL(5,2) NOT NULL, -- Điểm quy đổi thang 10
    CONSTRAINT FK_Attempts_Exams FOREIGN KEY (ExamId) REFERENCES Exams(Id) ON DELETE CASCADE
);

-- 6. Bảng Chi tiết câu trả lời của lượt thi (AttemptAnswers)
CREATE TABLE AttemptAnswers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AttemptId INT NOT NULL,
    QuestionId INT NOT NULL,
    SelectedOptionId INT NULL, -- NULL nếu thí sinh bỏ qua câu này
    IsCorrect BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_AttemptAnswers_Attempts FOREIGN KEY (AttemptId) REFERENCES ExamAttempts(Id) ON DELETE CASCADE,
    CONSTRAINT FK_AttemptAnswers_Questions FOREIGN KEY (QuestionId) REFERENCES Questions(Id)
);
```

---

## 5. KẾ HOẠCH XÂY DỰNG BACKEND (ASP.NET CORE MVC + WEB API)

### 5.1. Module Parser đọc file Word (`.docx`) & Kiểm tra toàn vẹn (All-or-Nothing)

* **Thư viện:** `DocumentFormat.OpenXml`.
* **Quy trình xử lý khi Giảng viên upload file `.docx`:**
  1. Đọc toàn bộ các đoạn văn (`Paragraph`), bảng (`Table`), và hình ảnh (`Drawing`/`Blip`) trong file `.docx`.
  2. Nếu có hình ảnh trong `[PASSAGE_START]...[PASSAGE_END]`, trích xuất lưu vào `wwwroot/uploads/exams/` và chèn thẻ `<img src="..." />` vào `ContentHtml`.
  3. **Validation nghiêm ngặt (Strict Validation):**
     * Kiểm tra các thẻ đóng/mở (`[Q: ...]`, `[Q_END]`, `[PASSAGE_START]`, `[PASSAGE_END]`).
     * Kiểm tra mỗi câu hỏi có đủ 4 đáp án `[A]`, `[B]`, `[C]`, `[D]` hay không.
     * Kiểm tra mỗi câu có đúng 1 thẻ `[ANS: X]` hợp lệ không.
     * Kiểm tra số thứ tự câu hỏi có liên tiếp và không bị trùng lặp không.
     * Kiểm tra câu hỏi thuộc Part 6 và Part 7 bắt buộc phải gắn với một Passage.
  4. **Cơ chế Hủy bỏ Toàn bộ (Rollback):**
     * Lưu tất cả các lỗi phát hiện được vào danh sách `List<string> ValidationErrors` (ghi rõ lỗi ở câu số mấy, dòng nào).
     * Nếu `ValidationErrors.Any() == true`: **Tuyệt đối không lưu bất kỳ dòng nào vào Database**, trả danh sách lỗi về giao diện Web để Giảng viên sửa file Word.
     * Chỉ khi `ValidationErrors.Count == 0` (chuẩn 100%) mới mở `Database.BeginTransaction()`, lưu toàn bộ Đề thi -> Đoạn văn -> Câu hỏi -> Đáp án và `Commit()`.

### 5.2. Các màn hình Web MVC dành cho Giảng viên (`/Admin/Exams`)

1. **Trang Danh sách & Upload Đề thi:**
   * Nút Upload file `.docx` kèm bảng thông báo lỗi chi tiết (nếu file sai chuẩn).
   * Danh sách các đề thi đã import kèm trạng thái: `Nháp (Draft)` hoặc `Đã xuất bản (Published)`.
   * Nút **"Xuất bản đề thi" (Publish)**: Bật/tắt trạng thái `IsPublished`. Chỉ những đề có `IsPublished = true` mới hiển thị trên app Flutter.
2. **Trang Xem trước & Chỉnh sửa Đề thi (Preview & Edit):**
   * Giảng viên bấm vào đề thi để rà soát lỗi chính tả, kiểm tra hình ảnh hiển thị, xem câu hỏi nhóm Part 6, 7.
   * Cung cấp Modal/Form cho phép sửa trực tiếp nội dung đoạn văn, câu hỏi, 4 đáp án, đáp án đúng và gợi ý (`Hint`) rồi cập nhật xuống SQL Server.
3. **Trang Thống kê & Phân tích (Dashboard Analytics):**
   * Hiển thị tổng số lượt làm bài (`COUNT(ExamAttempts)`) của từng đề.
   * Điểm trung bình (`AVG(Score)`) và số câu đúng trung bình.
   * **Top 10 câu hỏi nhiều sinh viên làm sai nhất:** Truy vấn từ bảng `AttemptAnswers` nơi `IsCorrect = 0`, nhóm theo `QuestionId`, sắp xếp giảm dần `TOP 10`.

### 5.3. Danh sách RESTful API cho ứng dụng Mobile Flutter (Không cần Token/Auth)

Tất cả các API dưới đây đều gắn `[AllowAnonymous]`:

1. `GET /api/mobile/exams`
   * **Mô tả:** Lấy danh sách các đề thi đã xuất bản (`IsPublished == true`).
   * **Response:** `[{ id, title, durationMinutes, totalQuestions, attemptCount }]`
2. `GET /api/mobile/exams/{id}/start`
   * **Mô tả:** Lấy toàn bộ cấu trúc đề thi để bắt đầu làm bài ngay.
   * **Xử lý hoán vị:** Nếu câu hỏi có `AllowShuffleQuestion == true`, hoán vị thứ tự trong nhóm; nếu `AllowShuffleOptions == true`, hoán vị thứ tự hiển thị các lựa chọn (nhưng vẫn giữ ID gốc để chấm điểm chính xác).
   * **Response:** Thông tin đề thi + Danh sách `Part 5` (câu hỏi đơn) + Danh sách `Part 6 & Part 7` (Passage kèm danh sách câu hỏi con).
3. `POST /api/mobile/exams/{id}/submit`
   * **Request Body:**
     ```json
     {
       "deviceIdentifier": "flutter-guest-device",
       "durationSeconds": 45,
       "answers": [
         { "questionId": 101, "selectedOptionId": 402 },
         { "questionId": 102, "selectedOptionId": 407 }
       ]
     }
     ```
   * **Quy tắc chấm điểm (Hỗ trợ nộp sớm 1-2 câu):**
     * Kiểm tra `answers.Count >= 1` (trừ trường hợp hết giờ `isTimeUp = true` thì cho phép `answers.Count == 0`).
     * So khớp từng câu trong `answers` với đáp án đúng của đề thi trong DB:
       * `CorrectCount`: Số câu người dùng đã chọn và chọn đúng.
       * `WrongCount`: Số câu người dùng đã chọn nhưng sai.
       * `SkippedCount`: $\text{TotalQuestions} - (\text{CorrectCount} + \text{WrongCount})$.
       * `Score`: Tính điểm theo thang 10: $\text{Score} = \text{ROUND}\left(\frac{\text{CorrectCount}}{\text{TotalQuestions}} \times 10, 2\right)$ kèm điểm quy đổi TOEIC Reading ($\text{CorrectCount} \times 5$, tối đa 495).
     * Lưu vào `ExamAttempts` và `AttemptAnswers`.
   * **Response:** Kết quả tổng quan (`score`, `correctCount`, `wrongCount`, `skippedCount`, `answeredCount`) + Danh sách chi tiết đáp án đúng & lời giải (`Hint`) của từng câu.

---

## 6. KẾ HOẠCH XÂY DỰNG FRONTEND MOBILE (FLUTTER)

### 6.1. Luồng trải nghiệm người dùng (UX Flow - Không Đăng Nhập)

```text
[Mở App Flutter] 
      │ (Vào thẳng, KHÔNG có màn hình Login/Register)
      ▼
[1. Màn hình Danh sách Đề thi (ExamListScreen)]
      │ Bấm vào 1 đề thi -> Bấm "Bắt đầu làm bài ngay"
      ▼
[2. Màn hình Làm bài thi (ExamRoomScreen)]
      ├── Đếm ngược 75:00 thời gian thực (Cảnh báo khi < 5 phút, tự thu bài khi về 00:00)
      ├── Chọn/Đổi/Hủy chọn đáp án (Lưu state tạm thời)
      ├── Làm tối thiểu 1-2 câu -> Nút "Nộp bài" sáng lên cho phép nộp ngay!
      │   (Hiển thị Dialog xác nhận số câu đã làm & số câu chưa hoàn thành)
      ▼
[3. Màn hình Kết quả & Xem lại bài (ExamResultScreen)]
      ├── Hiển thị Điểm số, Số câu Đúng / Sai / Bỏ qua
      └── Xem chi tiết đáp án đúng & Gợi ý (Hint) cho từng câu
```

### 6.2. Đặc tả chi tiết từng màn hình Flutter

#### A. Màn hình 1: Danh sách Đề thi (`ExamListScreen`)

* **AppBar:** Tiêu đề `"Luyện Thi TOEIC Reading"` kèm nút làm mới (Refresh).
* **Danh sách Card Đề thi:**
  * Hiển thị: Tên đề thi (VD: *TOEIC Reading Test 01 - EnglishTest Official* và *ETS TOEIC Reading Test 09*), Thời gian: `75 phút`, Số lượng câu hỏi.
  * Nút hành động nổi bật: **"Vào thi ngay"** (chuyển thẳng sang `ExamRoomScreen`).

#### B. Màn hình 2: Giao diện Làm bài (`ExamRoomScreen`) - *Trọng tâm 3 điểm*

1. **Thanh Header cố định (Top Bar):**
   * Đồng hồ đếm ngược thời gian thực (`75:00` -> `00:00`). Đổi màu cam khi còn `< 5 phút`, nhấp nháy đỏ khi còn `< 1 phút`. Khi về `00:00`: Khóa toàn bộ thao tác chọn đáp án, hiển thị thông báo hết giờ và tự động gọi API nộp bài.
   * Bộ đếm tiến độ: `Đã làm: X/N câu`.
   * Nút **"Nộp bài"**:
     * **Logic Nộp sớm (1-2 câu):** Ngay khi người dùng chọn đáp án cho ít nhất **1 câu** (`answeredQuestionIds.length >= 1`), nút **"Nộp bài"** cho phép bấm nộp ngay.
     * Nếu người dùng bấm "Nộp bài" khi chưa chọn câu nào (`answeredQuestionIds.isEmpty`), hiển thị SnackBar nhắc: *"Bạn vui lòng làm tối thiểu 1 - 2 câu trước khi nộp bài nhé!"*.
     * Khi đã làm $\ge 1$ câu và bấm "Nộp bài": Hiển thị hộp thoại xác nhận (AlertDialog):
       > *"Bạn đã hoàn thành **2** câu hỏi (còn **N - 2** câu chưa làm). Bạn có chắc chắn muốn nộp bài và chấm điểm ngay không?"*
       > `[Tiếp tục làm]` | `[Nộp bài tính điểm]`
2. **Khu vực Hiển thị Câu hỏi (Body - Tự động thích ứng theo Part):**
   * **Đối với Part 5 (Câu hỏi độc lập):** Hiển thị thẻ câu hỏi rõ ràng và 4 nút chọn `(A)`, `(B)`, `(C)`, `(D)`.
   * **Đối với Part 6 & Part 7 (Câu hỏi nhóm theo đoạn văn/hình ảnh):**
     * Chia màn hình thông minh (Split View):
       * **Nửa trên (45% chiều cao):** Hiển thị bài đọc (`ContentHtml` + Hình ảnh có hỗ trợ pinch-to-zoom). Các vị trí điền khuyết `[131]`, `[132]` được tô nổi bật (highlight).
       * **Nửa dưới (55% chiều cao):** Danh sách các câu hỏi phụ thuộc đi kèm bài đọc đó để người học vừa đọc đoạn văn vừa tích đáp án mà không bị trôi mất đề.
   * **Thao tác chọn & hủy đáp án:**
     * Bấm vào đáp án chưa chọn -> Chọn đáp án đó.
     * Bấm vào đáp án khác -> Đổi lựa chọn.
     * Bấm lại vào chính đáp án đang chọn (hoặc nút *"Bỏ chọn"*) -> Hủy lựa chọn câu đó về trạng thái chưa làm.
3. **Thanh điều hướng dưới (Bottom Navigation & Question Palette):**
   * Nút `Câu trước` | `Bảng câu hỏi` | `Câu tiếp`.
   * Khi bấm `Bảng câu hỏi`: Mở BottomSheet hiển thị lưới các ô số câu hỏi. Câu đã làm tô màu Xanh dương, câu chưa làm màu Xám, câu đang đứng có viền Đậm. Bấm vào số nào nhảy ngay tới câu đó.

#### C. Màn hình 3: Hiển thị Kết quả (`ExamResultScreen`)

* **Thẻ Tổng kết Điểm số:**
  * Điểm số lớn ở trung tâm (kèm số câu đã làm).
  * 3 chỉ số thống kê trực quan bằng biểu tượng màu:
    * 🟢 **Số câu Đúng:** `correctCount`
    * 🔴 **Số câu Sai:** `wrongCount`
    * ⚪ **Số câu Bỏ qua:** `skippedCount`
* **Danh sách Xem lại & Giải thích (Review Mode):**
  * Bộ lọc nhanh: `Tất cả` | `Câu đã làm` | `Câu đúng` | `Câu sai` | `Bỏ qua`.
  * Hiển thị đáp án người dùng đã chọn, đáp án đúng của đề thi và hộp **Gợi ý trả lời (`Hint`)** được lấy từ file Word.
* **Nút cuối trang:** `"Làm lại đề này"` hoặc `"Về danh sách đề thi"`.

---

## 7. DANH SÁCH NHIỆM VỤ TỪNG BƯỚC CHO CODING AGENT (EXECUTION CHECKLIST)

Coding Agent hãy thực hiện lần lượt theo 5 Phase sau:

### Phase 1: Tạo 2 File Word Đề Thi Mẫu (`sample_exams/*.docx`)
* [x] Viết script tự động tạo 2 file `.docx` chuẩn định dạng Tags ở Mục 3:
  1. `EnglishTest_Part5_Full_Tagged.docx` (Chứa trọn bộ 30 câu 101-130 từ `EnglishTest.pdf` + bài đọc Part 6 câu 131-134 từ `Đề thi giữa kỳ v2.pdf`).
  2. `ETS_Reading_Test09_Full_Tagged.docx` (Chứa 100 câu 101-200 từ `Reading v09.pdf`).

### Phase 2: Khởi tạo Backend & Cơ sở dữ liệu (Microsoft SQL Server)
* [x] Cấu hình chuỗi kết nối SQL Server trong `appsettings.json` của `GiuaKy.Web.Mvc`.
* [x] Tạo các Entity classes (`Exam`, `Passage`, `Question`, `QuestionOption`, `ExamAttempt`, `AttemptAnswer`) và cấu hình `DbContext` với Fluent API.
* [x] Chạy Migration để khởi tạo bảng trong Microsoft SQL Server và tự động Seed sẵn 1 đề thi đã xuất bản để mở app Flutter là thấy ngay.

### Phase 3: Xây dựng Backend Services & Giao diện Web Giảng viên
* [x] Cài đặt NuGet package `DocumentFormat.OpenXml`.
* [x] Viết `DocxExamParserService` để đọc file `.docx`, kiểm tra lỗi cú pháp/thiếu tag/sai thứ tự câu và đảm bảo cơ chế **Transaction All-or-Nothing** (hủy toàn bộ nếu có bất kỳ lỗi nào).
* [x] Xây dựng `ExamController` và các Razor Views cho Giảng viên:
  * Upload file `.docx` và hiển thị bảng báo lỗi chi tiết nếu file sai định dạng.
  * Xem trước (Preview) đề thi và chỉnh sửa nội dung câu hỏi/đoạn văn/đáp án.
  * Nút Xuất bản đề thi (`Publish`).
  * Trang Thống kê: Số lượt thi, điểm trung bình, và **Top 10 câu hỏi làm sai nhiều nhất**.
* [x] Xây dựng `MobileExamApiController` (`/api/mobile/exams/...`) với `[AllowAnonymous]` cho ứng dụng Flutter.

### Phase 4: Xây dựng Ứng dụng Mobile Flutter (`GiuaKy/frontend` / `lib`)
* [x] Cấu hình dependencies trong `pubspec.yaml`: `http`, `intl` và cấu hình kết nối API linh hoạt (`ApiConfig`).
* [x] Thiết lập `main.dart` mở trực tiếp vào `ExamListScreen` (**tuyệt đối không tạo màn hình Login/Register**).
* [x] Xây dựng `ExamRoomScreen` với:
  * Bộ đếm ngược 75 phút tự động nộp bài khi hết giờ.
  * Giao diện chia đôi màn hình (Split-view Passage + Questions) cho Part 6 & Part 7 (Passage 45% phía trên, câu hỏi 55% phía dưới).
  * Cho phép chọn, thay đổi hoặc bấm lại để hủy chọn đáp án (toggle off).
  * Bảng câu hỏi (Question Palette BottomSheet) hiển thị lưới số câu và nhảy nhanh.
  * Kiểm tra điều kiện nộp bài: **Chỉ cần làm tối thiểu 1 - 2 câu (`answeredCount >= 1`) là cho phép bấm Nộp bài**, hiển thị cảnh báo xác nhận số câu chưa làm và gửi dữ liệu chấm điểm.
* [x] Xây dựng `ExamResultScreen` hiển thị điểm số (thang 10 & TOEIC 495), tổng số câu Đúng / Sai / Bỏ qua và lời giải chi tiết (`Hint`) kèm bộ lọc câu hỏi.

### Phase 5: Kiểm thử Tích hợp (End-to-End Verification)
* [x] **Test 1:** Upload 1 file `.docx` cố tình thiếu đáp án `[D]` ở câu 105 (`EnglishTest_Invalid_MissingD.docx`) -> Hệ thống báo lỗi rõ: `Câu hỏi 105: Thiếu phương án lựa chọn [D]` và áp dụng cơ chế All-or-Nothing Rollback không lưu gì vào SQL Server.
* [x] **Test 2:** Upload file `EnglishTest_Part5_Full_Tagged.docx` chuẩn 100% -> Lưu thành công 34 câu hỏi vào SQL Server -> Xem trước, quản trị đề thi và xuất bản đề thi (`IsPublished = true`).
* [x] **Test 3:** Mở app Flutter -> Không cần đăng nhập, thấy ngay đề vừa xuất bản -> Bấm vào làm bài -> Chọn thử đúng **2 câu** (Câu 101 chọn `B`, Câu 102 chọn `C`) -> Bấm "Nộp bài" -> Xác nhận nộp -> Màn hình kết quả chấm điểm chính xác cho 2 câu đã làm (0.59/10, TOEIC 10/495, 32 câu bỏ qua), hiển thị gợi ý giải thích chi tiết -> Trang thống kê của Giảng viên (`/Exam/Analytics/1`) cập nhật ngay lượt thi và Top 10 câu sai.

---

## 8. KẾT LUẬN & TRẠNG THÁI TRIỂN KHAI TOÀN DIỆN
Toàn bộ 5 Phase theo đặc tả đã được xây dựng hoàn tất, tích hợp chặt chẽ và kiểm thử thành công:
1. **File Word Tag chuẩn:** 2 bộ đề chuẩn ETS hoàn chỉnh + 1 file test lỗi kiểm tra Rollback.
2. **Microsoft SQL Server:** 6 bảng CSDL hoạt động ổn định trên instance `.\MSSQLSERVER08`.
3. **Backend ASP.NET Core MVC + API:** Xử lý OpenXml All-or-Nothing, Web Quản lý & Thống kê Giảng viên, REST API `[AllowAnonymous]` trên cổng `5283`.
4. **Flutter Mobile:** Giao diện chuẩn Material 3, trải nghiệm No-Auth tức thì, Split-view bài đọc, Bảng câu hỏi thông minh, Nộp bài sớm từ 1 câu, và Trang kết quả giải thích `Hint`.
5. **Kiểm thử tự động:** `flutter analyze` 0 issues, `flutter test` (Smoke test + E2E integration test) 100% Passed.