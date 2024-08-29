# dart_cspell_cli

Github Action: https://github.com/fa0311/flutter_cspell

```ps1
dart run bin/dart_cspell_cli.dart flutter_cspell/flutter/packages/*/lib/**.dart -o output1.txt
npx cspell --no-color output1.txt > output2.txt
bin/run.ps1 output2.txt > output3.txt
```

```sh
dart run bin/dart_cspell_cli.dart flutter_cspell/flutter/packages/*/lib/**.dart -o output1.txt
npx cspell --no-color output1.txt > output2.txt
bin/run.sh output2.txt > output3.txt
```
