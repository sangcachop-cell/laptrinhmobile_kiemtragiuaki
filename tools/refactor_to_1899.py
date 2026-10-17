import os, shutil

backend_dir = r"d:\Flutter VS Code Project\KT\flutter_application_1\backend"
src_dir = os.path.join(backend_dir, "src")

old_id = "2380600189"
new_id = "2380601899"

# Copy Web.Mvc without bin/obj
old_mvc = os.path.join(src_dir, f"_{old_id}.Web.Mvc")
new_mvc = os.path.join(src_dir, f"_{new_id}.Web.Mvc")

if os.path.exists(old_mvc) and not os.path.exists(new_mvc):
    shutil.copytree(old_mvc, new_mvc, ignore=shutil.ignore_patterns("bin", "obj"))
    print(f"Copied _{old_id}.Web.Mvc -> _{new_id}.Web.Mvc")
    
    old_proj = os.path.join(new_mvc, f"_{old_id}.Web.Mvc.csproj")
    new_proj = os.path.join(new_mvc, f"_{new_id}.Web.Mvc.csproj")
    if os.path.exists(old_proj):
        os.rename(old_proj, new_proj)
        print(f"Renamed csproj: _{old_id}.Web.Mvc.csproj -> _{new_id}.Web.Mvc.csproj")

# Rename DbContext files
ef_dir = os.path.join(src_dir, f"_{new_id}.EntityFrameworkCore")
for f_sub in ["DbContext.cs", "DbContextFactory.cs"]:
    old_f = os.path.join(ef_dir, f"_{old_id}{f_sub}")
    new_f = os.path.join(ef_dir, f"_{new_id}{f_sub}")
    if os.path.exists(old_f):
        os.rename(old_f, new_f)
        print(f"Renamed {old_f} -> {new_f}")

# Replace content in all files
extensions = [".cs", ".csproj", ".cshtml", ".json", ".sln", ".slnx"]

for root, dirs, files in os.walk(backend_dir):
    if "bin" in root or "obj" in root or f"_{old_id}.Web.Mvc" in root:
        continue
    for f in files:
        if any(f.endswith(ext) for ext in extensions):
            file_path = os.path.join(root, f)
            try:
                with open(file_path, "r", encoding="utf-8") as fp:
                    content = fp.read()
                
                if old_id in content:
                    new_content = content.replace(old_id, new_id)
                    with open(file_path, "w", encoding="utf-8") as fp:
                        fp.write(new_content)
                    print(f"Updated: {f}")
            except Exception as e:
                print(f"Error updating {file_path}: {e}")

# Remove old migration folder
mig_dir = os.path.join(ef_dir, "Migrations")
if os.path.exists(mig_dir):
    shutil.rmtree(mig_dir)
    print("Cleared Migrations for fresh start")

# Remove old slnx
old_slnx = os.path.join(backend_dir, f"{old_id}.slnx")
if os.path.exists(old_slnx):
    os.remove(old_slnx)
    print(f"Removed {old_id}.slnx")

print("Backend refactored to 2380601899 successfully!")
