import docx, re, sys

sys.stdout.reconfigure(encoding='utf-8')

def test_docx(file_path):
    doc = docx.Document(file_path)
    full_text = '\n'.join([p.text for p in doc.paragraphs])
    
    title_match = re.search(r'\[EXAM_TITLE:\s*(.*?)\]', full_text)
    duration_match = re.search(r'\[EXAM_DURATION:\s*(\d+)\]', full_text)
    q_matches = re.findall(r'\[Q:\s*(\d+)\]', full_text)
    ans_matches = re.findall(r'\[ANS:\s*([A-D])\]', full_text)
    passages = re.findall(r'\[PASSAGE_START\]', full_text)
    
    title = title_match.group(1) if title_match else "N/A"
    duration = duration_match.group(1) if duration_match else "N/A"
    first_q = q_matches[0] if q_matches else "N/A"
    last_q = q_matches[-1] if q_matches else "N/A"
    
    print(f"File: {file_path}")
    print(f"  Title: {title}")
    print(f"  Duration: {duration} mins")
    print(f"  Total Questions: {len(q_matches)} (from {first_q} to {last_q})")
    print(f"  Total Answers: {len(ans_matches)}")
    print(f"  Total Passages: {len(passages)}")
    print("-" * 50)

test_docx('sample_exams/EnglishTest_Part5_Full_Tagged.docx')
test_docx('sample_exams/ETS_Reading_Test09_Full_Tagged.docx')
test_docx('sample_exams/EnglishTest_Invalid_MissingD.docx')
