// Main JavaScript file for client-side functionality

// Add current year to footer
document.addEventListener('DOMContentLoaded', () => {
    const footerYear = document.querySelector('footer p');
    if (footerYear) {
        const currentYear = new Date().getFullYear();
        footerYear.innerHTML = footerYear.innerHTML.replace('{{ current_year }}', currentYear);
    }
});
