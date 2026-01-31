// Portfolio Script

console.log('Portfolio script loaded');

// DOM Content Loaded Event
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM fully loaded');
    
    // Theme Toggle Functionality
    const themeToggle = document.getElementById('themeToggle');
    const body = document.body;
    
    // Log button dimensions and position for debugging
    const rect = themeToggle.getBoundingClientRect();
    console.log('Button dimensions:', rect.width, 'x', rect.height);
    console.log('Button position:', rect.left, ',', rect.top);
    console.log('Button center:', rect.left + rect.width/2, ',', rect.top + rect.height/2);
    
    // Set initial theme from localStorage or default to dark mode
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'light') {
        body.classList.add('light-mode');
        themeToggle.querySelector('i').classList.remove('fa-moon');
        themeToggle.querySelector('i').classList.add('fa-sun');
    } else {
        body.classList.remove('light-mode');
        themeToggle.querySelector('i').classList.remove('fa-sun');
        themeToggle.querySelector('i').classList.add('fa-moon');
    }
    
    // Add direct click listener to theme toggle
    themeToggle.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        // Toggle theme
        document.body.classList.toggle('light-mode');
        const icon = this.querySelector('i');
        if (document.body.classList.contains('light-mode')) {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
            localStorage.setItem('theme', 'light');
            console.log('Light mode enabled');
        } else {
            icon.classList.remove('fa-sun');
            icon.classList.add('fa-moon');
            localStorage.setItem('theme', 'dark');
            console.log('Dark mode enabled');
        }
    });
    
    // Template Switching Functionality
    const templateBtns = document.querySelectorAll('.template-btn');
    
    // Set initial template from localStorage or default to template1
    const savedTemplate = localStorage.getItem('template');
    if (savedTemplate === 'template2') {
        document.body.classList.add('template2');
        document.querySelector('[data-template="template1"]').classList.remove('active');
        document.querySelector('[data-template="template2"]').classList.add('active');
    } else {
        document.body.classList.remove('template2');
        document.querySelector('[data-template="template1"]').classList.add('active');
        document.querySelector('[data-template="template2"]').classList.remove('active');
    }
    
    templateBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const template = this.dataset.template;
            
            // Add transition animation
            document.body.classList.add('template-transition');
            
            // Remove active class from all buttons
            templateBtns.forEach(b => b.classList.remove('active'));
            
            // Add active class to clicked button
            this.classList.add('active');
            
            // Toggle template class
            if (template === 'template2') {
                document.body.classList.add('template2');
                localStorage.setItem('template', 'template2');
                console.log('Template 2 activated');
            } else {
                document.body.classList.remove('template2');
                localStorage.setItem('template', 'template1');
                console.log('Template 1 activated');
            }
            
            // Remove transition class after animation completes
            setTimeout(() => {
                document.body.classList.remove('template-transition');
            }, 800);
        });
    });
    
    // Active Section Indicator
    const sections = document.querySelectorAll('section[id]');
    
    const sectionObserver = new IntersectionObserver((entries) => {
        // Find the section with the highest visibility
        let currentSection = null;
        let highestRatio = 0;
        
        entries.forEach(entry => {
            if (entry.isIntersecting && entry.intersectionRatio > highestRatio) {
                highestRatio = entry.intersectionRatio;
                currentSection = entry.target;
            }
        });
        
        if (currentSection) {
            // Remove active class from all nav links
            const navLinks = document.querySelectorAll('nav a');
            navLinks.forEach(link => {
                link.classList.remove('active');
            });
            
            // Find and add active class to the corresponding nav link
            const sectionId = currentSection.getAttribute('id');
            const activeNavLink = document.querySelector(`nav a[href="#${sectionId}"]`);
            if (activeNavLink) {
                activeNavLink.classList.add('active');
            }
        }
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    });
    
    // Observe all sections with ids
    sections.forEach(section => {
        sectionObserver.observe(section);
    });
    
    console.log('Template switcher functionality ready');
    console.log('Theme toggle functionality ready');
    
    // Smooth Scrolling for Navigation Links
    const navLinks = document.querySelectorAll('nav a');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const targetId = this.getAttribute('href');
            if (targetId.startsWith('#')) {
                e.preventDefault();
                const targetSection = document.querySelector(targetId);
                if (targetSection) {
                    targetSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }
        });
    });
    
    // Animate Elements on Scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observe all animate-on-scroll elements
    const animateElements = document.querySelectorAll('.animate-on-scroll');
    animateElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
    
    // Navbar Background on Scroll
    window.addEventListener('scroll', function() {
        const navbar = document.querySelector('.navbar');
        const isLightMode = document.body.classList.contains('light-mode');
        
        if (window.pageYOffset > 100) {
            if (isLightMode) {
                navbar.style.background = 'rgba(255, 255, 255, 0.98)';
                navbar.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.1)';
            } else {
                navbar.style.background = 'rgba(10, 10, 10, 0.98)';
                navbar.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.3)';
            }
        } else {
            if (isLightMode) {
                navbar.style.background = 'rgba(255, 255, 255, 0.98)';
                navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
            } else {
                navbar.style.background = 'rgba(10, 10, 10, 0.95)';
                navbar.style.boxShadow = 'none';
            }
        }
    });
    
    // Project Cards Hover Effects
    const projectCards = document.querySelectorAll('.project-card');
    projectCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-8px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // Achievement Cards Hover Effects
    const achievementCards = document.querySelectorAll('.achievement-card');
    achievementCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-8px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // Skills Progress Bars Animation
    const skillsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const progressBars = entry.target.querySelectorAll('.progress');
                progressBars.forEach(bar => {
                    const width = bar.getAttribute('data-width');
                    bar.style.width = width;
                });
                skillsObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });
    
    const skillsSection = document.querySelector('#skills');
    if (skillsSection) {
        skillsObserver.observe(skillsSection);
    }
});
