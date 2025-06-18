// Main JavaScript file for client-side functionality

document.addEventListener('DOMContentLoaded', () => {
    // Add current year to footer
    const footerYear = document.querySelector('footer p');
    if (footerYear) {
        const currentYear = new Date().getFullYear();
        footerYear.innerHTML = footerYear.innerHTML.replace('{{ current_year }}', currentYear);
    }
    
    // Neo-brutalism interactions
    
    // Add random rotation to neo-brutal elements
    document.querySelectorAll('.neo-brutal-element').forEach(element => {
        // Apply a slight random rotation between -2 and 2 degrees
        const randomRotation = (Math.random() * 4 - 2).toFixed(2);
        element.style.transform = `rotate(${randomRotation}deg)`;
        
        // Add hover effect that straightens the element
        element.addEventListener('mouseover', () => {
            element.style.transform = 'rotate(0deg) translateY(-5px)';
        });
        
        // Restore original rotation on mouse out
        element.addEventListener('mouseout', () => {
            element.style.transform = `rotate(${randomRotation}deg)`;
        });
    });
    
    // Create floating background shapes
    createFloatingShapes();
    
    // Add wiggle animation to logo on hover
    const logo = document.querySelector('.logo');
    if (logo) {
        logo.addEventListener('mouseover', () => {
            logo.style.animation = 'wiggle 0.5s ease-in-out';
        });
        
        logo.addEventListener('animationend', () => {
            logo.style.animation = '';
        });
    }
});

// Function to create floating background shapes
function createFloatingShapes() {
    const colors = ['#FFFF03', '#ff2cc0', '#42eb42', '#1900ff'];
    const shapes = ['circle', 'square', 'triangle'];
    const container = document.body;
    
    // Create 5 random shapes
    for (let i = 0; i < 5; i++) {
        const shape = document.createElement('div');
        const randomColor = colors[Math.floor(Math.random() * colors.length)];
        const randomShape = shapes[Math.floor(Math.random() * shapes.length)];
        const size = Math.random() * 100 + 50;
        const posX = Math.random() * 100;
        const posY = Math.random() * 100;
        const animationDuration = Math.random() * 20 + 10;
        
        shape.style.position = 'fixed';
        shape.style.zIndex = '1';
        shape.style.width = `${size}px`;
        shape.style.height = `${size}px`;
        shape.style.backgroundColor = randomColor;
        shape.style.opacity = '0.2';
        shape.style.left = `${posX}%`;
        shape.style.top = `${posY}%`;
        shape.style.animation = `float ${animationDuration}s infinite ease-in-out`;
        
        if (randomShape === 'circle') {
            shape.style.borderRadius = '50%';
        } else if (randomShape === 'triangle') {
            shape.style.width = '0';
            shape.style.height = '0';
            shape.style.backgroundColor = 'transparent';
            shape.style.borderLeft = `${size/2}px solid transparent`;
            shape.style.borderRight = `${size/2}px solid transparent`;
            shape.style.borderBottom = `${size}px solid ${randomColor}`;
        } else {
            shape.style.transform = `rotate(${Math.random() * 45}deg)`;
        }
        
        container.appendChild(shape);
    }
}

// Define float animation
const styleSheet = document.createElement('style');
styleSheet.type = 'text/css';
styleSheet.innerText = `
@keyframes float {
    0% { transform: translateY(0) rotate(0); }
    50% { transform: translateY(-20px) rotate(5deg); }
    100% { transform: translateY(0) rotate(0); }
}
`;
document.head.appendChild(styleSheet);
