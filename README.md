# awakening-nginx-rtmp

Live streaming video server for Flash, iOS and Android

## Usage

Publishing is restricted to clients who supply the pre-shared `PUBLISH_SECRET`,
passed to the Docker container as an environment variable.

You must set the following environment variables:

 - `PUBLISH_SECRET`: Secret token for publishing and statistics.
 - `CORS_HTTP_ORIGIN`: HTTP origin regex to allow CORS on the /hls location.

This image exposes ports `80` for HTTP and `1935` for RTMP.

### Example

    docker run -e PUBLISH_SECRET=VERY_SECRET_KEY
               -e CORS_HTTP_ORIGIN='(https?://[^/]*\.yourdomain\.com(:[0-9]+)?)'
               -p 80:80 -p 1935:1935 zlwu/nginx-rtmp


## Publish URL

Set your RTMP encoder to publish to `rtmp://{your-server}/pub_{PUBLISH_SECRET}/{your-stream-name}`.

## Player URL

The stream can be viewed at `rtmp://{your-server}/player/{your-stream-name}`.

## HLS

HLS playlists are available at `http://{{your-server}/hls/{your-stream-name}.m3u8`.

## Statistics

The following resources are available:

 - `info`: General information
 - `stats`: XML of general information

Statistic URLs contain references to the `PUBLISH_SECRET`, so they are protected.
You can visit these protected resources by visiting `/p/{token}/{resource-name}`, where
`{token}` is set the the result of:

```
echo -n '{resource-name}{PUBLISH_SECRET}' | openssl md5 -hex
```

## License

MIT, see LICENSE file.
