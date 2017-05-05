# Webmail Lite Next

## Installation instructions

During installation process you will need:
* [Git](https://git-scm.com/downloads)
* [Composer](https://getcomposer.org/download/)
* [Node.js + NPM](https://nodejs.org/en/)

1. Download and unpack the latest version of aurora-framework into your installation root directory (currently it's version 0.3.1)
`https://github.com/afterlogic/aurora-framework/archive/master.zip`

2. Download `modules.json` from `https://raw.githubusercontent.com/afterlogic/webmail-lite-next
/master/modules.json` and override existing `modules.json` in root directory.

3. Download `composer.phar` from `https://getcomposer.org/composer.phar`

4. Run composer installation process by running the following from command line:
```bash
php composer.phar install
```

**NB:** It is strongly advised to run composer as non-root user. Otherwise, third-party scripts will be run with root permissions and composer issues a warning that it's not safe. We recommend running the script as the same user web server runs under.

This will install modules described in modules.json. At this moment aurora-bundle-files repository contains configs for Files bundle build.

After that, you need to build static files for current module set.

First of all, install all npm modules via
```bash
npm install
```
and install gulp-cli module globaly 
```bash
npm install --global gulp-cli
```

Now you can build static files
```bash
gulp styles --themes Default,Funny
```

```bash
gulp js:min
```

Upon installing the product, you'll need to [configure your installation](https://afterlogic.com/docs/aurora-cloud/configuration).

**IMPORTANT:**

1. Make sure data directory is writable by web server. For example:
```bash
chown -R www-data:www-data /var/www/webmail/data
```

2. It is strongly recommended to runs the product under **https**. If you run it under **http**, the majority of features will still be available, but some functionality aspects, such as authentication with Google account, won't work.

To enable automatic redirect from **http** to **https**, set **RedirectToHttps** to **On** in **data/settings/config.json** file.
