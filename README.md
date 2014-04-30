# fluent-plugin-tagged_copy

## About

Fluentd out\_copy extension to do tagging before passing to chained plugins

## Examples

```apache
<match **>
  type tagged_copy
  <store>
    <filter>
       add_tag_prefix foo
       remove_tag_prefix bar
    </filter>
    type stdout
  </store>

  <store>
    <filter>
       tag blah
    </filter>
    type stdout
  </store>
</match>
```

## Parameters

Basically same with out\_copy plugin. See http://docs.fluentd.org/articles/out_copy

But, you can specify `filter` directive with following options

* tag

    The tag name

* add_tag_prefix

    Add tag prefix for output message

* remove_tag_prefix

    Remove tag prefix for output message
    
* add_tag_suffix

    Add tag suffix for output message

* remove_tag_suffix

    Remove tag suffix for output message
    
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
