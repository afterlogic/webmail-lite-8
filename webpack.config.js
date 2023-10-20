const path = require('path');

module.exports = {
  mode: 'development',
  devServer: {
    static: {
      directory: path.join(__dirname, 'static/js'),
    },
    compress: true,
    port: 9000,
  },
};