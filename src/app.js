const menu = document.querySelector('[data-menu]');
const modal = document.querySelector('[data-modal]');
const result = document.querySelector('[data-launch-result]');

for (const button of document.querySelectorAll('[data-action]')) {
  button.addEventListener('click', () => {
    const action = button.dataset.action;
    if (action === 'menu') menu.classList.toggle('open');
    if (action === 'discover') modal.classList.toggle('open');
    if (action === 'contact') {
      result.textContent = 'CONTACT MODULE READY';
      modal.classList.add('open');
    }
    if (action === 'launch') {
      result.textContent = 'LAUNCH REQUEST QUEUED';
      setTimeout(() => (result.textContent = 'CLIENT STANDBY'), 1800);
    }
  });
}

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') {
    menu.classList.remove('open');
    modal.classList.remove('open');
  }
});
