# fluent-plugin-copy_ex

Fluentd out\_copy extension

## What is this for?

Think of `out_copy` configuration as folloings:

```apache
<match **>
  type copy
  <store>
    type plugin1
  </store>
  <store>
    type plugin2
  </store>
</match>
```

In the current Fluentd, when plugin1 raises an error internally, the chain is broken and the plugin2 is not executed. 

The `out_copy_ex` supplies `ignore_error` option so that it will not break the chain and the plugin2 is executed. 

See https://github.com/fluent/fluentd/pull/303 for discussions. 


## Configuration

```apache
<match **>
  type copy_ex
  <store ignore_error>
    type plugin1
  </store>
  <store ignore_error>
    type plugin2
  </store>
</match>
```

## Parameters

Basically same with out\_copy plugin. See http://docs.fluentd.org/articles/out_copy
    
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Copyright

* Copyright (c) 2014- Naotoshi Seo
* See [LICENSE](LICENSE) for details.
