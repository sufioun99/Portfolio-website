# Deployment Checklist for Portfolio Website

## ✅ Pre-Deployment Checks

### 1. File Structure
- ✅ Main HTML file: `index.html`
- ✅ CSS file: `css/styles.css`
- ✅ JavaScript file: `js/script.js`
- ✅ Project pages: `projects/` directory
- ✅ Oracle Forms files: `oracle-forms-files/` directory
- ✅ Images: `img/` directory

### 2. Link Validation
- ✅ Main page links to CSS and JavaScript
- ✅ Project pages link to CSS and JavaScript (relative paths)
- ✅ Navigation links in project pages point to correct locations
- ✅ Project links from main page point to project files
- ✅ Oracle Forms download links point to correct files

### 3. Resource Accessibility
- ✅ All images load correctly
- ✅ All CSS styles are applied
- ✅ JavaScript functionality works (theme toggle, template switcher, navigation)
- ✅ Project pages load and display properly

### 4. Responsive Design
- ✅ Website works on desktop
- ✅ Navigation and layout adapt to mobile devices
- ✅ Images are responsive

## 🚀 Deployment Options

### Option 1: GitHub Pages (Free)

1. **Create a new repository on GitHub**
   - Go to https://github.com
   - Click "New repository"
   - Choose a name (e.g., `portfolio`)
   - Make it public
   - Click "Create repository"

2. **Upload files**
   - Drag and drop all files from `portfolio-project/` directory to GitHub repository
   - Commit the changes

3. **Enable GitHub Pages**
   - Go to Repository Settings > Pages
   - Under "Source", select "Deploy from a branch"
   - Choose branch: `main` (or `master`)
   - Choose folder: `/ (root)`
   - Click "Save"

4. **Wait for deployment**
   - Your portfolio will be available at: `https://<your-username>.github.io/portfolio/`

### Option 2: Netlify (Free)

1. **Sign up for Netlify**
   - Go to https://www.netlify.com
   - Sign up with GitHub account

2. **Create a new site from Git**
   - Click "New site from Git"
   - Select GitHub
   - Authorize Netlify to access your repositories
   - Select your portfolio repository

3. **Configure build settings**
   - Branch to deploy: `main` (or `master`)
   - Build command: `(leave blank)`
   - Publish directory: `/portfolio-project`
   - Click "Deploy site"

4. **Custom domain (optional)**
   - Netlify will provide a default domain (e.g., `your-site-name.netlify.app`)
   - You can connect your custom domain if you have one

### Option 3: Vercel (Free)

1. **Sign up for Vercel**
   - Go to https://vercel.com
   - Sign up with GitHub account

2. **Import your repository**
   - Click "New Project"
   - Import your portfolio repository
   - Click "Deploy"

3. **Custom domain (optional)**
   - Vercel will provide a default domain (e.g., `your-site-name.vercel.app`)
   - You can connect your custom domain if you have one

### Option 4: Local Server (Testing)

If you want to test locally before deployment:

```bash
# Navigate to portfolio directory
cd "f:/VS CODE/As Nasim - Porfolio/portfolio-project"

# Start local server
python -m http.server 8000
```

Then open your browser and go to `http://localhost:8000`

## 📁 Project Structure
```
portfolio-project/
├── index.html              # Main portfolio page
├── css/
│   └── styles.css          # Global styles
├── js/
│   └── script.js           # JavaScript functionality
├── img/                    # Images
│   ├── home-Profile.png
│   ├── About-profile.png
│   └── ...
├── projects/               # Project pages
│   ├── inventory-management.html
│   ├── enterprise-reporting.html
│   ├── oracle-forms-project.html
│   └── ...
├── oracle-forms-files/     # Oracle Forms downloads
│   └── ...
└── README.md               # Project information
```

## 🎨 Customization

### Updating Content
- **Personal information**: Edit `index.html`
- **Projects**: Modify project cards in `index.html` and project pages in `projects/`
- **Skills**: Update skills grid in `index.html`
- **Certifications**: Add/remove certificates in `index.html`

### Styling
- **Colors**: Modify CSS variables in `styles.css`
- **Fonts**: Change Google Fonts link in `index.html`
- **Layout**: Adjust grid and flex properties in `styles.css`

## 🔄 Post-Deployment

After deployment:
1. Test all links to ensure they're working
2. Check website performance
3. Verify responsiveness on mobile devices
4. Monitor server logs for errors

## 📞 Support

If you encounter any issues:
1. Check browser console for errors
2. Verify file paths are correct
3. Ensure all resources are properly uploaded
4. Check hosting platform's help center

---

**Happy Deploying! 🎉**
