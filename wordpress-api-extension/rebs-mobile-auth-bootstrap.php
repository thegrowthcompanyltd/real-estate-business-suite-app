<?php
/**
 * Bootstrap snippet for the Real Estate Business Suite plugin.
 *
 * Copy this file into the plugin's includes directory and require it from
 * real-estate-business-suite.php after class-rebs-rest.php:
 * require_once REBS_PATH . 'includes/class-rebs-mobile-auth.php';
 * REBS_Mobile_Auth::instance();
 */
if (!defined('ABSPATH')) exit;

require_once REBS_PATH . 'includes/class-rebs-mobile-auth.php';
if (method_exists('REBS_Mobile_Auth', 'instance')) {
    REBS_Mobile_Auth::instance();
} else {
    new REBS_Mobile_Auth();
}
