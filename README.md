[![Build Status](https://travis-ci.org/afterlogic/webmail-lite-8.svg?branch=master)](https://travis-ci.org/afterlogic/webmail-lite-8)

# Afterlogic WebMail Lite 8
Open-source webmail script for your existing IMAP server.

- For more information, please visit WebMail Lite [home page](https://afterlogic.org/webmail-lite).
- You can check WebMail Lite 8 [live demo](https://lite.afterlogic.com).
- [Github repository](https://github.com/afterlogic/webmail-lite-8)
- [Issue tracker](https://github.com/afterlogic/webmail-lite-8/issues)

![Afterlogic WebMail Lite 8: Message List](https://afterlogic.org/images/products/wml8/afterlogic-webmail-lite-8-message-list.png)

You can download WebMail Lite 8 from our website, unzip the package and configure the installation as described at [this documentation page](https://afterlogic.com/docs/webmail-lite-8/installation/installation-instructions). This is a simple approach convenient for those who simply wish to install the product. But if you're looking for building and adding custom modules or skins, installing from Git repository is recommended per the instructions below.

## Installation instructions

During installation process you will need:
* [Git](https://git-scm.com/downloads)
* [Composer](https://getcomposer.org/download/)
* [Node.js + NPM](https://nodejs.org/en/)
    
    **Note!** npm 3.0 or later is required.

1. Download and unpack the latest version of WebMail Lite 8 into your installation root directory
`https://github.com/afterlogic/webmail-lite-8/archive/latest.zip`

We're assuming that you wish to install the latest stable version of the product. If you're looking for the latest code (e.g., to contribute changes), the following steps needs to be taken:

- Instead of unpacking the archive, clone the repository into the installation directory:
```
git clone https://github.com/afterlogic/webmail-lite-8.git INSTALL_FOLDER_PATH
```
- change modules' versions in `modules.json` file to "dev-master"
- adjust `composer.json` configuration file so that sources are preferred:
```
{
	"config": {
		"minimum-stability": "dev",
		"preferred-install": {
			"afterlogic/*": "source"
		}
	}.......
```

2. Download `composer.phar` from `https://getcomposer.org/composer.phar`

3. Start the composer installation process by running the following from the command line:
    ```bash
    php composer.phar install
    ```

    **NB:** It is strongly advised to run composer as non-root user. Otherwise, third-party scripts will be run with root permissions and composer issues a warning that it's not safe. We recommend running the script under the same user web server runs under.

4. Set up initial config values
    ```bash
    php composer.phar run pre-config
    ```

5. Next, you need to build static files for the current module set.

    First of all, install all npm modules via
    ```bash
    npm install
    ```
    and install gulp-cli module globaly 
    ```bash
    npm install --global gulp-cli
    ```

6. Now you can build static files
    ```bash
    gulp styles --themes Default,DeepForest,Funny,Sand
    ```

    ```bash
    gulp js:min
    ```
  
7. Now you are ready to open a URL pointing to the installation directory in your favorite web browser.

8. Upon installing the product, you'll need to [configure your installation](https://afterlogic.com/docs/webmail-lite-8/configuring-webmail).

**IMPORTANT:**

1. Make sure data directory is writable by the web server. For example:
  ```bash
  chown -R www-data:www-data /var/www/webmail/data
  ```

2. It is strongly recommended to runs the product via **https**. If you run it via **http**, the majority of features will still be available, but some functionality aspects, such as authentication with Google account, won't work.

To enable automatic redirect from **http** to **https**, set **RedirectToHttps** to **true** in **data/settings/config.json** file.

**Protecting data directory:**

All configuration files of the application and user data are stored in data directory, so it's important to [protect data directory](https://afterlogic.com/docs/webmail-lite-8/security/protecting-data-directory) to make sure that  nobody can access that directory over the Internet directly. 

# Licensing
This product is licensed under AGPLv3. The modules and other packages included in this product as dependencies are licensed under their own licenses.

NB: Afterlogic Aurora modules which have dual licensing are licensed under AGPLv3 within this product.
