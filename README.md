# Web::Fetcher

Sample project to implement web content fetcher.

## Usage

```console
$ rake build
$ docker run --rm -ti web-fetcher https://udzura.jp <...>

# If you want to get files, assets from a docker container
$ docker run --rm -ti \
    -v /tmp/out:/tmp/out \
    -e WEB_FETCHER_DEST_DIR=/tmp/out \
    web-fetcher https://udzura.jp <...>
```

### Show metadata

```
$ docker run --rm -ti web-fetcher --metadata https://udzura.jp <...>
```
### Download all assets

```
$ docker run --rm -ti web-fetcher --download-assets https://udzura.jp <...>
```

## Elapsed time for implementation

* Design, research ... about 1 hours
* Basic, Show metadata ... about 2 hours [`87094a1a030b514e63b40e6dc27d3762b3111d43`](https://github.com/udzura/web-fetcher/commit/87094a1a030b514e63b40e6dc27d3762b3111d43) ~ [`7216112102a061b66765f950b14a0f558abef1a7`](https://github.com/udzura/web-fetcher/commit/7216112102a061b66765f950b14a0f558abef1a7)
* Download all assets ...  about 1 hours [`29925b43ed7bc78f490940a0e42ecf8f2616fbe9`](https://github.com/udzura/web-fetcher/commit/29925b43ed7bc78f490940a0e42ecf8f2616fbe9) ~ [`6a228678e008a29be1c1b04719a173e72bfb5ab6`](https://github.com/udzura/web-fetcher/commit/6a228678e008a29be1c1b04719a173e72bfb5ab6)

## TODO

* [ ] Simple E2E test, using rack-based mock server...
