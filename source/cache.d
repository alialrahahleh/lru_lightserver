import std.container : DList;
import std.stdio;

import dlist: CDList, Item;


class Cache {

    private:

    Item[string] list;
    CDList lru;
    size_t limit;
    auto size = 0;

    public: 

    this(size_t limit) {
        this.limit = limit;
        this.lru = new CDList();
    }

    void add(string key, string value) {
        if(size == limit) {
            cleanUp();
        }
        Item item;
        if (!exists(key)) {
            item = new Item(value, key);
            list[key] = item;
            lru.push(item);
        } else {
            item = list[key];
            item.value = value;
        }
        size++;
    }
    void cleanUp() {
        if (lru.empty()) {
            return;
        }
        auto leastUsed = lru.front();
        lru.remove(leastUsed);
        list.remove(leastUsed.key);
        size--;
    }
    string getOr(string key, string def) {
        if(exists(key)) {
            return get(key);
        }
        return def;
    }
    string get(string key) { 
        lru.remove(list[key]);
        lru.push(list[key]);
        return list[key].value;
    }
    bool exists(string key) {
        Item *exist = (key in list);
        return exist !is null;
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
        assert(equal(cache.lru.keys(), ["ali", "ali3", "ali4"]));  

        Cache cache2 = new Cache(3);
        cache2.add("c_2_1", "koko");
        cache2.add("c_2_2", "koko");
        cache2.add("c_2_3", "koko");
        cache2.get("c_2_1");
        cache2.get("c_2_2");
        cache2.get("c_2_3");
        cache2.add("c_2_4", "koko");
        assert(equal(cache2.lru.keys(), ["c_2_2", "c_2_3", "c_2_4"])); 

        Cache cache3 = new Cache(3);
        cache3.add("ali", "koko");
        cache3.add("ali", "koko");
        cache3.add("ali", "koko");
        cache3.get("ali");
        cache3.get("ali");
        cache3.get("ali");
        cache3.add("ali", "koko");
        assert(equal(cache3.lru.keys(), ["ali"]));  

        Cache cache4 = new Cache(3);
        cache4.add("ali", "koko"); 
        assert(cache4.exists("ali") == true);
        assert(cache4.exists("doesntexists") == false);
        // return value if key exists
        assert(cache4.getOr("ali", "someDefault") == "koko");
        // return default if key doesn't exists
        assert(cache4.getOr("koko", "someDefault") == "someDefault");
    }

}
