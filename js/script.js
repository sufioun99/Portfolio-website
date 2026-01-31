// Portfolio Script - Enhanced with Dynamic Features

console.log('Portfolio script loaded');

// Performance optimization: Debounce function
function debounce(func, wait = 16) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Performance optimization: Throttle function
function throttle(func, limit = 16) {
    let inThrottle;
    return function executedFunction(...args) {
        if (!inThrottle) {
            func(...args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// DOM Content Loaded Event
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM fully loaded');
    
    // Hide loading overlay quickly
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        requestAnimationFrame(() => {
            overlay.classList.add('hidden');
        });
    }
    
    // Initialize all features
    initParticleBackground();
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
    initParallaxEffect();
    initCounterAnimations();
    initMouseCursor();
    initLazyLoading();
    initTiltEffects();
    initMagneticButtons();
});

// Particle Background Effect
function initParticleBackground() {
    const hero = document.querySelector('.hero');
    if (!hero) return;
    
    // Create canvas for particles
    const canvas = document.createElement('canvas');
    canvas.id = 'particleCanvas';
    canvas.style.position = 'absolute';
    canvas.style.top = '0';
    canvas.style.left = '0';
    canvas.style.width = '100%';
    canvas.style.height = '100%';
    canvas.style.pointerEvents = 'none';
    canvas.style.zIndex = '1';
    hero.style.position = 'relative';
    hero.insertBefore(canvas, hero.firstChild);
    
    const ctx = canvas.getContext('2d');
    let particles = [];
    
    function resizeCanvas() {
        canvas.width = hero.offsetWidth;
        canvas.height = hero.offsetHeight;
    }
    
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    
    // Particle class
    class Particle {
        constructor() {
            this.x = Math.random() * canvas.width;
            this.y = Math.random() * canvas.height;
            this.size = Math.random() * 3 + 1;
            this.speedX = Math.random() * 1 - 0.5;
            this.speedY = Math.random() * 1 - 0.5;
            this.opacity = Math.random() * 0.5 + 0.2;
            this.color = getComputedStyle(document.body).getPropertyValue('--accent-primary').trim() || '#6366f1';
        }
        
        update() {
            this.x += this.speedX;
            this.y += this.speedY;
            
            if (this.x > canvas.width) this.x = 0;
            if (this.x < 0) this.x = canvas.width;
            if (this.y > canvas.height) this.y = 0;
            if (this.y < 0) this.y = canvas.height;
        }
        
        draw() {
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fillStyle = this.color;
            ctx.globalAlpha = this.opacity;
            ctx.fill();
            ctx.globalAlpha = 1;
        }
    }
    
    // Create particles
    function initParticles() {
        particles = [];
        const particleCount = Math.min(50, Math.floor(canvas.width / 20));
        for (let i = 0; i < particleCount; i++) {
            particles.push(new Particle());
        }
    }
    
    initParticles();
    
    // Animation loop
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        particles.forEach(particle => {
            particle.update();
            particle.draw();
        });
        requestAnimationFrame(animate);
    }
    
    animate();
    
    // Update particles on resize
    window.addEventListener('resize', () => {
        resizeCanvas();
        initParticles();
    });
}

// Parallax Scrolling Effect - Optimized with throttling
function initParallaxEffect() {
    const hero = document.querySelector('.hero');
    const heroImage = document.querySelector('.hero-image');
    
    if (!hero || !heroImage) return;
    
    let ticking = false;
    
    const updateParallax = throttle(() => {
        const scrollY = window.pageYOffset;
        const windowHeight = window.innerHeight;
        
        // Parallax for hero image
        if (scrollY < windowHeight) {
            heroImage.style.transform = `translateY(${scrollY * 0.3}px)`;
            heroImage.style.opacity = 1 - scrollY / windowHeight;
            heroImage.style.willChange = 'transform, opacity';
        }
        
        // Parallax for particles
        const particles = document.getElementById('particleCanvas');
        if (particles) {
            particles.style.transform = `translateY(${scrollY * 0.5}px)`;
        }
    }, 16);
    
    // Use passive listener for better scroll performance
    window.addEventListener('scroll', updateParallax, { passive: true });
}

// Counter Animation for Stats
function initCounterAnimations() {
    const counters = document.querySelectorAll('.counter');
    
    if (!counters.length) return;
    
    const counterObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const counter = entry.target;
                const target = parseInt(counter.getAttribute('data-target'));
                const duration = 2000;
                const step = target / (duration / 16);
                let current = 0;
                
                const updateCounter = () => {
                    current += step;
                    if (current < target) {
                        counter.textContent = Math.floor(current);
                        requestAnimationFrame(updateCounter);
                    } else {
                        counter.textContent = target;
                    }
                };
                
                updateCounter();
                counterObserver.unobserve(counter);
            }
        });
    }, { threshold: 0.5 });
    
    counters.forEach(counter => counterObserver.observe(counter));
}

// Custom Mouse Cursor
function initMouseCursor() {
    const cursor = document.createElement('div');
    cursor.className = 'custom-cursor';
    cursor.style.cssText = `
        position: fixed;
        width: 20px;
        height: 20px;
        border: 2px solid var(--accent-primary, #6366f1);
        border-radius: 50%;
        pointer-events: none;
        z-index: 9999;
        transform: translate(-50%, -50%);
        transition: transform 0.1s ease, width 0.2s ease, height 0.2s ease, border-color 0.2s ease;
        mix-blend-mode: difference;
    `;
    document.body.appendChild(cursor);
    
    const cursorFollower = document.createElement('div');
    cursorFollower.className = 'cursor-follower';
    cursorFollower.style.cssText = `
        position: fixed;
        width: 8px;
        height: 8px;
        background: var(--accent-primary, #6366f1);
        border-radius: 50%;
        pointer-events: none;
        z-index: 9999;
        transform: translate(-50%, -50%);
        transition: transform 0.15s ease-out;
    `;
    document.body.appendChild(cursorFollower);
    
    let mouseX = 0, mouseY = 0;
    let cursorX = 0, cursorY = 0;
    let followerX = 0, followerY = 0;
    
    document.addEventListener('mousemove', (e) => {
        mouseX = e.clientX;
        mouseY = e.clientY;
        cursor.style.left = mouseX + 'px';
        cursor.style.top = mouseY + 'px';
    });
    
    // Smooth cursor animation
    function animateCursor() {
        cursorX += (mouseX - cursorX) * 0.2;
        cursorY += (mouseY - cursorY) * 0.2;
        followerX += (mouseX - followerX) * 0.3;
        followerY += (mouseY - followerY) * 0.3;
        
        cursor.style.transform = `translate(${cursorX}px, ${cursorY}px) translate(-50%, -50%)`;
        cursorFollower.style.transform = `translate(${followerX}px, ${followerY}px) translate(-50%, -50%)`;
        
        requestAnimationFrame(animateCursor);
    }
    
    animateCursor();
    
    // Hover effects
    const interactiveElements = document.querySelectorAll('a, button, .project-card, .achievement-card, .skill-category');
    
    interactiveElements.forEach(el => {
        el.addEventListener('mouseenter', () => {
            cursor.style.width = '40px';
            cursor.style.height = '40px';
            cursor.style.borderWidth = '3px';
        });
        
        el.addEventListener('mouseleave', () => {
            cursor.style.width = '20px';
            cursor.style.height = '20px';
            cursor.style.borderWidth = '2px';
        });
    });
    
    // Hide cursor when leaving window
    document.addEventListener('mouseleave', () => {
        cursor.style.opacity = '0';
        cursorFollower.style.opacity = '0';
    });
    
    document.addEventListener('mouseenter', () => {
        cursor.style.opacity = '1';
        cursorFollower.style.opacity = '1';
    });
    
    // Check for touch devices
    if ('ontouchstart' in window) {
        cursor.style.display = 'none';
        cursorFollower.style.display = 'none';
    }
}

// Lazy Loading Images
function initLazyLoading() {
    const images = document.querySelectorAll('img[data-src]');
    
    if (!images.length) return;
    
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.removeAttribute('data-src');
                img.classList.add('loaded');
                imageObserver.unobserve(img);
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '50px'
    });
    
    images.forEach(img => imageObserver.observe(img));
}

// 3D Tilt Effect for Cards
function initTiltEffects() {
    const tiltCards = document.querySelectorAll('.project-card, .achievement-card');
    
    tiltCards.forEach(card => {
        card.style.transformStyle = 'preserve-3d';
        card.style.perspective = '1000px';
        
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = (y - centerY) / 20;
            const rotateY = (centerX - x) / 20;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale3d(1, 1, 1)';
        });
    });
}

// Magnetic Button Effect
function initMagneticButtons() {
    const buttons = document.querySelectorAll('.btn');
    
    buttons.forEach(button => {
        button.addEventListener('mousemove', (e) => {
            const rect = button.getBoundingClientRect();
            const x = e.clientX - rect.left - rect.width / 2;
            const y = e.clientY - rect.top - rect.height / 2;
            
            button.style.transform = `translate(${x * 0.3}px, ${y * 0.3}px)`;
        });
        
        button.addEventListener('mouseleave', () => {
            button.style.transform = '';
        });
    });
}

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

// Update theme toggle icon based on current state
function updateThemeToggleIcon() {
    const themeToggle = document.getElementById('themeToggle');
    if (!themeToggle) return;
    
    const icon = themeToggle.querySelector('i');
    if (!icon) return;
    
    const isLightMode = document.body.classList.contains('light-mode');
    if (isLightMode) {
        icon.classList.remove('fa-moon');
        icon.classList.add('fa-sun');
    } else {
        icon.classList.remove('fa-sun');
        icon.classList.add('fa-moon');
    }
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
    
    // Update theme toggle icon to match current theme
    updateThemeToggleIcon();
    
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
            
            // Update theme toggle icon to match current theme
            updateThemeToggleIcon();
            
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

// Scroll Progress Indicator - Optimized with passive listener
function initScrollProgress() {
    const scrollProgress = document.getElementById('scrollProgress');
    
    const updateProgress = throttle(() => {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const scrollHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrollPercentage = (scrollTop / scrollHeight) * 100;
        scrollProgress.style.width = scrollPercentage + '%';
    }, 16);
    
    window.addEventListener('scroll', updateProgress, { passive: true });
}

// Back to Top Button
function initBackToTop() {
    const backToTop = document.getElementById('backToTop');
    
    if (!backToTop) return;
    
    // Create progress indicator SVG
    const progressContainer = document.createElement('div');
    progressContainer.className = 'back-to-top-progress';
    progressContainer.innerHTML = `
        <svg viewBox="0 0 50 50">
            <circle class="bg" cx="25" cy="25" r="20"></circle>
            <circle class="progress" cx="25" cy="25" r="20"></circle>
        </svg>
    `;
    backToTop.parentNode.insertBefore(progressContainer, backToTop);
    
    const progressCircle = progressContainer.querySelector('.progress');
    
    // Update button visibility and progress on scroll - Optimized
    const updateBackToTop = throttle(() => {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const scrollHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrollPercentage = (scrollTop / scrollHeight) * 100;
        
        // Show button after 300px scroll
        if (scrollTop > 300) {
            backToTop.classList.add('visible');
        } else {
            backToTop.classList.remove('visible');
        }
        
        // Update progress circle (126 is the circumference: 2 * π * 20)
        const offset = 126 - (126 * scrollPercentage / 100);
        progressCircle.style.strokeDashoffset = offset;
    }, 16);
    
    window.addEventListener('scroll', updateBackToTop, { passive: true });
    updateBackToTop(); // Initial check
    
    // Smooth scroll to top with animation
    backToTop.addEventListener('click', function(e) {
        // Create ripple effect
        const ripple = document.createElement('span');
        ripple.className = 'ripple';
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
        ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';
        this.appendChild(ripple);
        
        setTimeout(() => ripple.remove(), 600);
        
        // Smooth scroll to top
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
    
    // Add hover animation to icon
    backToTop.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-5px) scale(1.05)';
    });
    
    backToTop.addEventListener('mouseleave', function() {
        this.style.transform = '';
    });
    
    // Add active state
    backToTop.addEventListener('mousedown', function() {
        this.style.transform = 'translateY(-2px) scale(1.02)';
    });
    
    backToTop.addEventListener('mouseup', function() {
        this.style.transform = '';
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

// Navbar Background on Scroll - Optimized
const updateNavbar = throttle(() => {
    const navbar = document.querySelector('.navbar');
    if (!navbar) return;
    
    if (window.pageYOffset > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
}, 16);

window.addEventListener('scroll', updateNavbar, { passive: true });

// Initial check
updateNavbar();

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
