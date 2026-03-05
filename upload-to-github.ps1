# Upload this project to GitHub as uvm-crc-8-16
# Prereq: Create a new repo on GitHub named "uvm-crc-8-16" (empty, no README).
# Then run this script from the repo root (DUTs/crc-8-16).

$repoName = "uvm-crc-8-16"
$branch = "main"

# Rename branch to main if currently master
if ((git branch --show-current) -eq "master") {
    git branch -M main
}

# Replace YOUR_USERNAME with your GitHub username
$remote = "https://github.com/YOUR_USERNAME/$repoName.git"
Write-Host "Add remote and push to $remote"
Write-Host "Edit this script to set YOUR_USERNAME, or run:"
Write-Host "  git remote add origin https://github.com/YOUR_USERNAME/$repoName.git"
Write-Host "  git push -u origin main"
Write-Host ""

$user = Read-Host "Enter your GitHub username (or press Enter to skip remote add)"
if ($user) {
    git remote remove origin 2>$null
    git remote add origin "https://github.com/$user/$repoName.git"
    git push -u origin main
}
