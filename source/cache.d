import std.container : DList;
import std.stdio;


struct Item {
    string value;
}
class Cache {
    private:
    Item[string] list;
    private size_t limit;
    auto lru = DList!string();
    auto size = 0;
    public: 

    this(size_t limit) {
        this.limit = limit;
    }

    void add(string key, string value) {
        if(size == limit) {
            cleanUp();
        }
        Item *exist = (key in list);
        if (exist is null) {
            lru.insertFront(key);
            size++;
        }
        Item item;
        item.value = value; 
        list[key] = item;
    }
    void cleanUp() {
        if (lru.empty) {
            return;
        }
        string last = lru.back();
        lru.removeBack();
        list.remove(last);
        size--;
    }
    string get(string key) { 
        lru.linearRemoveElement(key);
        lru.insertFront(key);
        return list[key].value;
    }
    void dump() {
        writeln("Dumping values ");
        foreach(string item; lru) {
            writeln("Item in cache is ", item);
        }
        writeln("--------------------------------------");
    }
    unittest 
    {
        import std.algorithm.comparison: equal;
        Cache cache = new Cache(3);
        cache.add("ali", "koko");
        cache.add("ali2", "koko");
        cache.add("ali3", "koko");
        cache.get("ali");
        cache.get("ali3");
        cache.add("ali4", "koko");
        assert(equal(cache.lru[], ["ali4", "ali3", "ali"]));

        Cache cache2 = new Cache(3);
        cache2.add("ali", "koko");
        cache2.add("ali2", "koko");
        cache2.add("ali3", "koko");
        cache2.get("ali");
        cache2.get("ali3");
        cache2.get("ali");
        cache2.add("ali4", "koko");
        assert(equal(cache2.lru[], ["ali4", "ali", "ali3"])); 

        Cache cache3 = new Cache(3);
        cache3.add("ali", "koko");
        cache3.add("ali", "koko");
        cache3.add("ali", "koko");
        cache3.get("ali");
        cache3.get("ali");
        cache3.get("ali");
        cache3.add("ali", "koko");
        assert(equal(cache3.lru[], ["ali"]));  
    }

}
