
<a id="0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d_validation"></a>

# Module `0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d::validation`

@title Validation
@notice A library for validating transactions


-  [Constants](#@Constants_0)
-  [Function `check_deadline`](#0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d_validation_check_deadline)


<pre><code><b>use</b> <a href="">0x1::timestamp</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d_validation_ERR_TRANSACTION_EXPIRED"></a>



<pre><code><b>const</b> <a href="validation.md#0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d_validation_ERR_TRANSACTION_EXPIRED">ERR_TRANSACTION_EXPIRED</a>: u64 = 1;
</code></pre>



<a id="0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d_validation_check_deadline"></a>

## Function `check_deadline`



<pre><code><b>public</b> <b>fun</b> <a href="validation.md#0x13253effc048095b933b0d2ffe307913b074fb3b9f56780cc2495e18f0e6e14d_validation_check_deadline">check_deadline</a>(deadline: u64)
</code></pre>
