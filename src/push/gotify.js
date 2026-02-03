const priority = parseInt(process.env.GOTIFY_PRIORITY || '5', 10);

module.exports = {
  url: (process.env.GOTIFY_URL || '').replace(/\/+$/, ''),
  token: process.env.GOTIFY_TOKEN || '',
  priority: Number.isNaN(priority) || priority < 0 || priority > 10 ? 5 : priority,
};
