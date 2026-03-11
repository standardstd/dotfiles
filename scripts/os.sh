#!/usr/bin/env bash

detect_os() {

  case "$(uname -s)" in

    Linux*)
      OS="linux"
      ;;

    Darwin*)
      OS="mac"
      ;;

    CYGWIN*|MINGW*|MSYS*)
      OS="windows"
      ;;

    *)
      OS="unknown"
      ;;

  esac

  echo $OS
}