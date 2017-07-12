# Afterlogic WebMail Lite 8
Open-source webmail script for your existing IMAP server.
For more informaition please visit WebMail Lite [home page](https://afterlogic.org/webmail-lite-8). Look at WebMail Lite 8 [live demo](https://lite8.afterlogic.com).

![Afterlogic Webmail Lite 8: Message List](https://afterlogic.org/images/products/wml8/afterlogic-webmail-lite-8-message-list.png)

## Installation instructions

During installation process you will need:
* [Git](https://git-scm.com/downloads)
* [Composer](https://getcomposer.org/download/)
* [Node.js + NPM](https://nodejs.org/en/)
    
    **Note!** Version of npm above 3 is required

1. Download and unpack the latest version of Webmail Lite 8 into your installation root directory (currently it's version 0.5.0)
`https://github.com/afterlogic/webmail-lite-8/archive/0.5.0.zip`

2. Download `composer.phar` from `https://getcomposer.org/composer.phar`

3. Run composer installation process by running the following from command line:
    ```bash
    php composer.phar install
    ```

    **NB:** It is strongly advised to run composer as non-root user. Otherwise, third-party scripts will be run with root permissions and composer issues a warning that it's not safe. We recommend running the script as the same user web server runs under.

5. Next, you need to build static files for current module set.

    First of all, install all npm modules via
    ```bash
    npm install ./modules/CoreWebclient
    ```
    and install gulp-cli module globaly 
    ```bash
    npm install --global gulp-cli
    ```

6. Now you can build static files
    ```bash
    gulp styles --themes Default,Funny
    ```

    ```bash
    gulp js:min
    ```
  
7. Now you are ready to open a URL pointing to the installation directory in your favorite web browser.

8. Upon installing the product, you'll need to [configure your installation](https://afterlogic.com/docs/webmail-lite-8/configuring-webmail).

**IMPORTANT:**

1. Make sure data directory is writable by web server. For example:
  ```bash
  chown -R www-data:www-data /var/www/webmail/data
  ```

2. It is strongly recommended to runs the product under **https**. If you run it under **http**, the majority of features will still be available, but some functionality aspects, such as authentication with Google account, won't work.

To enable automatic redirect from **http** to **https**, set **RedirectToHttps** to **On** in **data/settings/config.json** file.

**Protecting data directory:**

All configuration files of the application and user data are stored in data directory, so it's important to [protect data directory](https://afterlogic.com/docs/webmail-lite-8/security/protecting-data-directory) to make sure that users cannot access that directory over the Internet directly. 
