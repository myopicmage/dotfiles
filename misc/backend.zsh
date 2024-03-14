function startbackend() {
  if lsof -Pi :5000 -sTCP:LISTEN -c Control -a -t > /dev/null ; then
    echo "AirPlay Receiver is using port 5000"
    return 1
  fi

  docker info &> /dev/null

  if [[ $? -gt 0 ]]; then
    echo "Docker is not running. Starting..."
    open -a Docker
  fi

  case $PWD/ in
    */uplift-backend/*) make start;;
    *) echo "Currently in $PWD, need to be in backend folder";;
  esac
}
