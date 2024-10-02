XSS_OBJ_O = screenhack.o fps.o
XSS_OBJ_U = resources.o visual.o usleep.o yarandom.o utf8wc.o font-retry.o xmu.o xft.o xdbe.o hsv.o colors.o

utils:
	$(MAKE) -C ../utils $(XSS_OBJ_U) CFLAGS='-fPIC'
objs:
	$(MAKE) -C ./ $(XSS_OBJ_O) CFLAGS='-fPIC'

cleanu:
	$(MAKE) -C ../utils clean
clean:
	$(RM) \
	  $(XSS_OBJ_O) \
	  #Eol
