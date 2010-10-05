File.open(File.join(File.dirname(__FILE__), 'Makefile'), 'w') do |f|
  f.puts <<-MAKEFILE
EXAMPLES = syntax

CFLAGS = -g3 -Wall -std=gnu99
all : $(EXAMPLES)

syntax : .FORCE
	mkdir -p bin
	$(CC) $(CFLAGS) -c bstrlib.c
	$(CC) $(CFLAGS) -c syntax.leg.c
	$(CC) $(CFLAGS) -c list.c
	$(CC) $(CFLAGS) -o parser syntax.leg.o bstrlib.o list.o

clean : .FORCE
	rm -rf bin/* *~ *.o *.[pl]eg.[cd] $(EXAMPLES)

.FORCE :
  MAKEFILE
end
