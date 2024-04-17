<?php
        // Check if Zend Thread Safety is enabled
        if (function_exists('zend_thread_id')) {
            echo "<p>ZTS is enabled on this PHP installation.</p>";
        } else {
            echo "<p>ZTS is not enabled on this PHP installation.</p>";
        }
    ?>