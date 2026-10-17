import os, shutil

backend_dir = r"d:\Flutter VS Code Project\KT\flutter_application_1\backend"
src_dir = os.path.join(backend_dir, "src")

old_mvc = os.path.join(src_dir, "GiuaKy.Web.Mvc")
new_mvc = os.path.join(src_dir, "_2380600189.Web.Mvc")

if os.path.exists(old_mvc) and not os.path.exists(new_mvc):
    shutil.copytree(old_mvc, new_mvc, ignore=shutil.ignore_patterns("bin", "obj"))
    print("Copied GiuaKy.Web.Mvc -> _2380600189.Web.Mvc (ignoring bin/obj)")
    
    old_csproj = os.path.join(new_mvc, "GiuaKy.Web.Mvc.csproj")
    new_csproj = os.path.join(new_mvc, "_2380600189.Web.Mvc.csproj")
    if os.path.exists(old_csproj):
        os.rename(old_csproj, new_csproj)
        print("Renamed csproj to _2380600189.Web.Mvc.csproj")

# Update references and namespace in all text files
extensions = [".cs", ".csproj", ".cshtml", ".json", ".sln"]

for root, dirs, files in os.walk(src_dir):
    if "bin" in root or "obj" in root or "GiuaKy.Web.Mvc" in root:
        continue
    for f in files:
        if any(f.endswith(ext) for ext in extensions):
            file_path = os.path.join(root, f)
            try:
                with open(file_path, "r", encoding="utf-8") as fp:
                    content = fp.read()
                
                new_content = content.replace("GiuaKy.Core", "_2380600189.Core")
                new_content = new_content.replace("GiuaKy.Application", "_2380600189.Application")
                new_content = new_content.replace("GiuaKy.EntityFrameworkCore", "_2380600189.EntityFrameworkCore")
                new_content = new_content.replace("GiuaKy.Web.Mvc", "_2380600189.Web.Mvc")
                new_content = new_content.replace("namespace GiuaKy", "namespace _2380600189")
                new_content = new_content.replace("using GiuaKy", "using _2380600189")
                new_content = new_content.replace("GiuaKyDbContext", "_2380600189DbContext")
                new_content = new_content.replace("GiuaKyToeicDb", "2380600189Db")

                if new_content != content:
                    with open(file_path, "w", encoding="utf-8") as fp:
                        fp.write(new_content)
                    print(f"Updated: {f}")
            except Exception as e:
                print(f"Error updating {file_path}: {e}")

# Rename DbContext files if needed
ef_dir = os.path.join(src_dir, "_2380600189.EntityFrameworkCore")
for f_old, f_new in [("GiuaKyDbContext.cs", "_2380600189DbContext.cs"), ("GiuaKyDbContextFactory.cs", "_2380600189DbContextFactory.cs")]:
    old_f_path = os.path.join(ef_dir, f_old)
    new_f_path = os.path.join(ef_dir, f_new)
    if os.path.exists(old_f_path):
        os.rename(old_f_path, new_f_path)
        print(f"Renamed {f_old} -> {f_new}")

# Clear old migrations for clean initial migration for 2380600189Db
mig_dir = os.path.join(ef_dir, "Migrations")
if os.path.exists(mig_dir):
    shutil.rmtree(mig_dir)
    print("Cleared old migrations for clean fresh start")

print("All files processed!")
