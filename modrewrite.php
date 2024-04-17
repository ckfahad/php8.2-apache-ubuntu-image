<?php
// Check if mod_rewrite is enabled
$modRewriteEnabled = function_exists('apache_get_modules') && in_array('mod_rewrite', apache_get_modules());

// Output the result
if ($modRewriteEnabled) {
    echo "mod_rewrite is enabled and working properly!";
} else {
    echo "mod_rewrite is not enabled or not working.";
}
?>
