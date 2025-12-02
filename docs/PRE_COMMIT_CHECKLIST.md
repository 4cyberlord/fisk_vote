# Pre-Commit Checklist

Before pushing to GitHub, ensure the following:

## ✅ Files to Ignore (Already in .gitignore)

### Root Level
- ✅ `node_modules/` - Node.js dependencies
- ✅ `vendor/` - Composer dependencies
- ✅ `.env` files - Environment variables
- ✅ `.DS_Store` - macOS system files
- ✅ IDE files (`.idea/`, `.vscode/`, etc.)

### Backend (Laravel)
- ✅ `/backend/vendor/` - PHP dependencies
- ✅ `/backend/.env` - Laravel environment file
- ✅ `/backend/storage/*.key` - Storage keys
- ✅ `/backend/storage/logs/*.log` - Log files
- ✅ `/backend/public/storage` - Public storage symlink
- ✅ `/backend/public/build` - Build artifacts
- ✅ `/backend/public/hot` - Vite hot file

### Frontend (Next.js)
- ✅ `/client/node_modules/` - Node.js dependencies
- ✅ `/client/.next/` - Next.js build output
- ✅ `/client/.env*` - Environment files
- ✅ `/client/out/` - Static export output
- ✅ `/client/.vercel/` - Vercel deployment files

## 🔒 Sensitive Files to NEVER Commit

1. **Environment Files**
   - `backend/.env`
   - `client/.env.local`
   - `client/.env.production.local`
   - Any file containing API keys, secrets, or passwords

2. **Keys and Certificates**
   - `*.key` files
   - `*.pem` files
   - Private keys

3. **Database Files**
   - SQLite database files (`.sqlite`, `.db`)
   - Database dumps with sensitive data

4. **Credentials**
   - `auth.json` (Composer auth)
   - Any file with passwords or tokens

## 📝 Files to Keep (Should be Committed)

### Configuration Examples
- ✅ `backend/.env.example` - Example environment file
- ✅ `composer.json` - PHP dependencies manifest
- ✅ `package.json` - Node.js dependencies manifest
- ✅ `composer.lock` - Locked PHP dependencies (optional, but recommended)
- ✅ `package-lock.json` - Locked Node.js dependencies (optional, but recommended)

### Documentation
- ✅ All `.md` files
- ✅ `README.md` files

### Source Code
- ✅ All source files (`.php`, `.ts`, `.tsx`, `.js`, `.jsx`)
- ✅ Configuration files (`.json`, `.yaml`, `.yml`)
- ✅ Migration files
- ✅ Seeders

## 🚀 Initial Git Setup Commands

If you haven't initialized git yet:

```bash
# Initialize git repository
git init

# Add all files (respecting .gitignore)
git add .

# Check what will be committed
git status

# Create initial commit
git commit -m "Initial commit: Fisk Voting System"

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## 🔍 Verify Before Pushing

Run these commands to verify nothing sensitive is being committed:

```bash
# Check for .env files
git ls-files | grep -E "\.env$|\.env\."

# Check for key files
git ls-files | grep -E "\.key$|\.pem$"

# Check for node_modules
git ls-files | grep node_modules

# Check for vendor
git ls-files | grep vendor

# View all files that will be committed
git ls-files
```

## 📋 Recommended .env.example Files

### backend/.env.example
Should include:
- Database configuration (without real credentials)
- App configuration
- JWT secret placeholder
- Mail configuration (without real credentials)
- CORS allowed origins

### client/.env.local.example
Should include:
- `NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1`
- `NEXT_PUBLIC_APP_URL=http://localhost:3000`

## ⚠️ Important Notes

1. **Never commit real credentials** - Always use `.env.example` files
2. **Review `git status`** before every commit
3. **Use `git diff`** to review changes before committing
4. **Keep `.gitignore` updated** as the project grows
5. **Consider using Git hooks** to prevent accidental commits of sensitive files

## 🛡️ Additional Security Recommendations

1. **Use environment variables** for all secrets
2. **Rotate secrets** if accidentally committed (even if quickly removed)
3. **Use GitHub Secrets** for CI/CD pipelines
4. **Enable branch protection** on main/master branch
5. **Review access permissions** on the repository

