/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        '../templates/**/*.html',
        '../../templates/**/*.html',
        '../../**/templates/**/*.html',
    ],
    darkMode: 'class', // КРИТИЧНО для нашей смены темы
    theme: {
        extend: {
            colors: {
                jira: {
                    bg: 'var(--jira-bg)',
                    panel: 'var(--jira-panel)',
                    card: 'var(--jira-card)',
                    cardHover: 'var(--jira-card-hover)',
                    border: 'var(--jira-border)',
                    text: 'var(--jira-text)',
                    textBright: 'var(--jira-text-bright)',
                    primary: 'var(--jira-primary)',
                    primaryHover: 'var(--jira-primary-hover)',
                    accent: 'var(--jira-accent)',
                    accentBg: 'var(--jira-accent-bg)',
                }
            },
            fontFamily: {
                sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', 'sans-serif'],
            }
        },
    },
    plugins: [
        require('daisyui'),
    ],
}
