### CloudlogBashCat

A simple script to keep Cloudlog in synch with rigctld.
It also runs rigctl using env params.
This can also run within docker.

Here is an example docker run command:
```
docker run \
  -e cloudlogRadioId="7300" \
  -e cloudlogApiKey="apikey" \
  -e cloudlogBaseURL="http://localhost" \
  -e rigctlRadioId=3073 \
  --device=/dev/ttyUSB0 \
  georgesoteriou/cloudlogrigctl:latest
```