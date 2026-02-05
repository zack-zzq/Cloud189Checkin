const parsePriority = (value) => {
  const parsed = parseInt(value || '5', 10);
  if (Number.isNaN(parsed) || parsed < 1 || parsed > 10) {
    return 5;
  }
  return parsed;
};

module.exports = {
  url: process.env.GOTIFY_URL || '',
  token: process.env.GOTIFY_TOKEN || '',
  priority: parsePriority(process.env.GOTIFY_PRIORITY),
  title: process.env.GOTIFY_TITLE || '',
};
