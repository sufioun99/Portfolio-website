// Portfolio Script - Enhanced with Dynamic Features

console.log('Portfolio script loaded');

// DOM Content Loaded Event
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM fully loaded');
    
    // Hide loading overlay
    setTimeout(() => {
        document.getElementById('loadingOverlay').classList.add('hidden');
    }, 500);
    
    // Initialize all features
    initThemeToggle();
    initTemplateSwitcher();
    initMobileMenu();
    initScrollProgress();
    initBackToTop();
    initScrollAnimations();
    initActiveSectionIndicator();
    initSmoothScrolling();
    initTypingAnimation();
    initCardHoverEffects();
});

// Theme Toggle Functionality
function initThemeToggle() {
    const themeToggle = document.getElementById('themeToggle');
    
    if (!themeToggle) {
        console.error('Theme toggle button not found');
        return;
    }
    
    const body = document.body;
    const icon = themeToggle.querySelector('i');
    
    // Set initial theme from localStorage or default to dark mode
    const savedTheme = localStorage.getItem('theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    // Determine initial theme: saved preference > system preference > dark mode
    let isLightMode = false;
    if (savedTheme === 'light') {
        isLightMode = true;
    } else if (savedTheme === 'dark') {
        isLightMode = false;
    } else if (!savedTheme && !prefersDark) {
        isLightMode = true;
    }
    
    // Apply initial theme
    if (isLightMode) {
        body.classList.add('light-mode');
        if (icon) {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
        }
    } else {
        body.classList.remove('light-mode');
        if (icon) {
            icon.classList.remove('fa-sun');
            icon.classList.add('fa-moon');
        }
    }
    
    // Add click listener to theme toggle
    themeToggle.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        // Toggle light-mode class
        body.classList.toggle('light-mode');
        const currentIcon = this.querySelector('i');
        
        if (body.classList.contains('light-mode')) {
            if (currentIcon) {
                currentIcon.classList.remove('fa-moon');
                currentIcon.classList.add('fa-sun');
            }
            localStorage.setItem('theme', 'light');
            console.log('Light mode enabled');
        } else {
            if (currentIcon) {
                currentIcon.classList.remove('fa-sun');
                currentIcon.classList.add('fa-moon');
            }
            localStorage.setItem('theme', 'dark');
            console.log('Dark mode enabled');
        }
        
        // Update CSS custom properties for smooth transition
        document.documentElement.style.setProperty('--transition-duration', '0.3s');
    });
    
    // Listen for system theme changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
        // Only auto-switch if user hasn't set a preference
        if (!localStorage.getItem('theme')) {
            if (e.matches) {
                body.classList.remove('light-mode');
                if (icon) {
                    icon.classList.remove('fa-sun');
                    icon.classList.add('fa-moon');
                }
            } else {
                body.classList.add('light-mode');
                if (icon) {
                    icon.classList.remove('fa-moon');
                    icon.classList.add('fa-sun');
                }
            }
        }
    });
}

// Template Switching Functionality
function initTemplateSwitcher() {
    const templateBtns = document.querySelectorAll('.template-btn');
    
    // Set initial template from localStorage or default to template1
    const savedTemplate = localStorage.getItem('template');
    const validTemplates = ['template1', 'template2', 'template3', 'template4', 'template5'];
    const currentTemplate = validTemplates.includes(savedTemplate) ? savedTemplate : 'template1';
    
    // Remove all template classes
    document.body.classList.remove('template1', 'template2', 'template3', 'template4', 'template5');
    
    // Add current template class
    document.body.classList.add(currentTemplate);
    
    // Update button states
    templateBtns.forEach(btn => {
        if (btn.dataset.template === currentTemplate) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });
    
    templateBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const template = this.dataset.template;
            
            // Add transition animation
            document.body.classList.add('template-transition');
            
            // Remove active class from all buttons
            templateBtns.forEach(b => b.classList.remove('active'));
            
            // Add active class to clicked button
            this.classList.add('active');
            
            // Remove all template classes
            document.body.classList.remove('template1', 'template2', 'template3', 'template4', 'template5');
            
            // Add selected template class
            document.body.classList.add(template);
            localStorage.setItem('template', template);
            
            console.log(template + ' activated');
            
            // Remove transition class after animation completes
            setTimeout(() => {
                document.body.classList.remove('template-transition');
            }, 800);
        });
    });
}

// Mobile Menu Toggle
function initMobileMenu() {
    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    const navMenu = document.getElementById('navMenu');
    
    if (mobileMenuToggle && navMenu) {
        mobileMenuToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            const icon = this.querySelector('i');
            if (navMenu.classList.contains('active')) {
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            } else {
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });
        
        // Close menu when clicking on a nav link
        navMenu.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('active');
                const icon = mobileMenuToggle.querySelector('i');
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            });
        });
    }
}

// Scroll Progress Indicator
function initScrollProgress() {
    const scrollProgress = document.getElementById('scrollProgress');
    
    window.addEventListener('scroll', function() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const scrollHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrollPercentage = (scrollTop / scrollHeight) * 100;
        scrollProgress.style.width = scrollPercentage + '%';
    });
}

// Back to Top Button
function initBackToTop() {
    const backToTop = document.getElementById('backToTop');
    
    window.addEventListener('scroll', function() {
        if (window.pageYOffset > 300) {
            backToTop.classList.add('visible');
        } else {
            backToTop.classList.remove('visible');
        }
    });
    
    backToTop.addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

// Scroll Animations
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, observerOptions);
    
    // Observe all animate-on-scroll elements
    const animateElements = document.querySelectorAll('.animate-on-scroll');
    animateElements.forEach(el => {
        observer.observe(el);
    });
    
    // Observe stagger items
    const staggerItems = document.querySelectorAll('.stagger-item');
    staggerItems.forEach((el, index) => {
        el.style.transitionDelay = `${index * 0.1}s`;
        observer.observe(el);
    });
}

// Active Section Indicator
function initActiveSectionIndicator() {
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
}

// Smooth Scrolling for Navigation Links
function initSmoothScrolling() {
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
}

// Typing Animation
function initTypingAnimation() {
    const typingText = document.getElementById('typingText');
    if (!typingText) return;
    
    const texts = [
        'Data Analyst | Database Developer',
        'Oracle APEX & Forms Developer',
        'Report Developer | Mathematician'
    ];
    let textIndex = 0;
    let charIndex = 0;
    let isDeleting = false;
    let typeSpeed = 100;
    
    function type() {
        const currentText = texts[textIndex];
        
        if (isDeleting) {
            typingText.textContent = currentText.substring(0, charIndex - 1);
            charIndex--;
            typeSpeed = 50;
        } else {
            typingText.textContent = currentText.substring(0, charIndex + 1);
            charIndex++;
            typeSpeed = 100;
        }
        
        if (!isDeleting && charIndex === currentText.length) {
            isDeleting = true;
            typeSpeed = 2000; // Pause at end
        } else if (isDeleting && charIndex === 0) {
            isDeleting = false;
            textIndex = (textIndex + 1) % texts.length;
            typeSpeed = 500; // Pause before typing next
        }
        
        setTimeout(type, typeSpeed);
    }
    
    // Start typing animation
    setTimeout(type, 1000);
}

// Card Hover Effects
function initCardHoverEffects() {
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
    
    // Skill Category Hover Effects
    const skillCategories = document.querySelectorAll('.skill-category');
    skillCategories.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // Education Card Hover Effects
    const educationCards = document.querySelectorAll('.education-card');
    educationCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // Certificate Card Hover Effects
    const certificateCards = document.querySelectorAll('.certificate-card');
    certificateCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
    
    // Contact Item Hover Effects
    const contactItems = document.querySelectorAll('.contact-item');
    contactItems.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateX(5px)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateX(0)';
        });
    });
}

// Navbar Background on Scroll
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    
    if (window.pageYOffset > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
});

// Skills Progress Bars Animation (if any)
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

console.log('All portfolio features initialized');
