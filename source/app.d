import std.stdio;
import std.algorithm;
import std.range;
import std.algorithm.comparison : equal;
import std.container : DList;
import cache;
import std.container;
import std.container.util;

import std.conv: to;
import std.array: split;

import std.socket : InternetAddress, Socket, SocketException, SocketSet, TcpSocket;


struct ErrorMessage  {
    static add = "Added Successfully";
    static success = "Added Successfully";
    static error_parsing_command =  "Error Parsing Command";
    static cmd_not_found = "Command not found";
    static argument_missing = "Arguemnt not complete";
    static item_doesnt_exits = "ITEM_DOESNT_EXISTS";
};

enum MAX_CONNECTIONS = 60;

string commandParser (string cmdList, Cache cache, ref Array!string results) {
    import std.string: lineSplitter, chomp;
    foreach(string command; cmdList.lineSplitter()) {
        string[] list = split(command, ":");
        if(list.length < 1)
        {
            return ErrorMessage.error_parsing_command;
        }
        switch(list[0]) {
            case "get":
                if(list.length < 2) {
                    return ErrorMessage.argument_missing;
                }
                results.insertBack(cache.getOr(list[1],
                            ErrorMessage.item_doesnt_exits));
                break;
            case "add":
                if(list.length < 3) {
                    return ErrorMessage.argument_missing;
                }
                cache.add(list[1], list[2]);
                break;
            default:
                return ErrorMessage.cmd_not_found;
        }
    }
    return ErrorMessage.success;
}

void main()
{
    import std.algorithm: cmp;
    import std.string: chomp;

    ushort port = 4444;
    auto listener = new TcpSocket();
    immutable size_t cache_max_size = 1000;
    listener.blocking = false;
    listener.bind(new InternetAddress(port));
    listener.listen(MAX_CONNECTIONS);
    Cache cache = new Cache(1000);


    auto socketSet = new SocketSet(MAX_CONNECTIONS + 1);
    Socket[] reads;

    while (true) {
        socketSet.add(listener);
        foreach (sock; reads)
            socketSet.add(sock);
        Socket.select(socketSet, null, null);
        for(size_t i = 0; i < reads.length; i++) {
            if (socketSet.isSet(reads[i])) {
                char[1024] buf;
                auto dataLength  = reads[i].receive(buf[]);
                if (dataLength == Socket.ERROR) {
                    writeln("Connection Error.");
                } else if (dataLength > 0) {
                    string item = chomp(to!string(buf[0..dataLength]));
                    if(cmp(item, "close") == 0) {
                        reads[i].close();
                        reads = reads.remove(i);
                        i--; 
                        break;
                    }
                    auto result =  make!(Array!string)();
                    commandParser(item, cache, result);
                    foreach(string t; result) {
                        reads[i].send(t);
                    }
                } else {
                    reads[i].close();
                    reads = reads.remove(i);
                }
                writefln("Total connections: %d", reads.length);
            }
        }
        if (socketSet.isSet(listener)) {
            Socket sn = null;
            scope (failure) 
            {
                writefln("Error accepting");
                if (sn)
                    sn.close();
            }
            sn = listener.accept();
            assert(sn.isAlive);
            assert(listener.isAlive);

            if (reads.length < MAX_CONNECTIONS) {
                writefln("Connection from %s established.",
                        sn.remoteAddress().toString());
                reads ~= sn;
                writefln("\t Total connections: %d", reads.length);
            }
            else 
            {
                writefln("Rejected connection from %s; too man connections.",
                        sn.remoteAddress().toString());
                sn.close();
                assert(!sn.isAlive);
                assert(listener.isAlive);
            }
        }
        socketSet.reset();
    }
}
