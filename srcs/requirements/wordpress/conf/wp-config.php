<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress_db' );

/** Database username */
define( 'DB_USER', 'wordpress_user' );

/** Database password */
define( 'DB_PASSWORD', 'placeholder' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          'H1vGL@`5W~3&*#{@(Rd5.c<P];&V,m4eRrxGC,559A/9jX^#klARlZuh5i(s^9N1' );
define( 'SECURE_AUTH_KEY',   '^,e$@p]re%vxT?{pSe;5} ]R+EM7T4Z,I/M{-!(v~s/yNrZ}[^}hfFzL-PArj1NO' );
define( 'LOGGED_IN_KEY',     '{=q$3m&m_)w1GO/NRWmp[!i9|e/nqG<.}V.Q2XylUnw2nt&pIVtD>2Or]sud}er ' );
define( 'NONCE_KEY',         'YH&(L 7C^<se[*f;E26I|b:h#kd0@0K i:-6GEEjW!h Uy:|`}`p*0/yDEK+`{5m' );
define( 'AUTH_SALT',         '-Mv@U7j-,G{VF{2}H{V$}5.jMiYMNFRm4@Uu[MdoiHp,2zZE8HvyiDL-WCvuD{*L' );
define( 'SECURE_AUTH_SALT',  '#)#+4p30]UvjTdlGw]!7W%Vg^fD9ZM[l%nt!AUWwN0`H/.0_#3oj0`WMb|[3_)9)' );
define( 'LOGGED_IN_SALT',    '$`ZpfuyT<3G|K;ZR&0 @%q/+DoP,^]QL:Bt|qhF>aKgeQ}(V32|yNsr!aS%|1;tS' );
define( 'NONCE_SALT',        '3Y5keWGSk;>S9~ @pThss7!9KaN.ClI/+7S1!Ky*n3~P;uOrhoK@OqL=3eK>Y@a0' );
define( 'WP_CACHE_KEY_SALT', 'h%0l*G%1w2f!IUf5DmD&&qIM%nq8?Q/n)HIq*QdK xg5pM$faF8-sYYU<(Xgjzt.' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
        define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
define('DISALLOW_FILE_EDIT', true);

/** Redis specific settings */
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', '6379');
define('WP_REDIS_DATABASE', '0');
