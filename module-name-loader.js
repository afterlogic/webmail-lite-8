// const path = require('path');

module.exports = function(source) {
    // get the file name without extension
    // const fileName = path.basename(this.resourcePath, '.js');
    const fileName = this.resourcePath.match(/modules\/(.*?)\//)[1];
    
    // replace the placeholder with the file name
    const result = source.replace(/%ModuleName%/g, fileName);
    // return the modified source
    return result;
};