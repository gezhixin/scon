cmd_Release/bonjour.node := c++ -bundle -undefined dynamic_lookup -Wl,-no_pie -Wl,-search_paths_first -mmacosx-version-min=10.10 -arch x86_64 -L./Release -stdlib=libc++  -o Release/bonjour.node Release/obj.target/bonjour/Bonjour.o Release/obj.target/bonjour/BonjourJSBridge.o -framework Foundation