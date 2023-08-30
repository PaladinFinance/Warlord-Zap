#Generate coverage report
forge coverage --report lcov

#Remove unwanted files
lcov --remove lcov.info -o lcov.info 'script/*' 'test/*'

#Generate html file
genhtml lcov.info -o ./coverage

#Remove lcov file
rm lcov.info
