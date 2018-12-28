import std.stdio : writeln;

class Item {
    public:
    this(string v,string k = "") {
        this.value = v;
        this.key   = k;
        this.next = null;
        this.prev = null;
    }
    string value;
    string key;
    private:
    Item next;
    Item prev;
} 
class CDList {

    private: 
        Item head, tail;
        size_t size = 0; 
    public:
        Item push(Item item) {
            if(head is null) {
                head = item;
                tail = head;
            } else {
                tail.next = item;
                item.prev = tail;
                tail = item;
            }
            size++;
            return item;
        }

        public auto length() {
            return size;
        }

        void remove(Item item) {
            if(size == 0) {
                return;
            }
            if(item.prev) {
                item.prev.next = item.next;
            } 
            if(item.next) {
                item.next.prev = item.prev;
            }
            if(head == item) {
                head = item.next;
            }
            if(tail == item) {
                tail = item.prev;
            }
            item.next = null;
            item.prev = null;
            size--;
        }
        string[] keys() {
            string[] list = new string[size];
            size_t i = 0;
            for(Item c = head; c !is null; c = c.next) {
                list[i++] = c.key;
            }
            return list;
        } 
        string[] toArray() {
            string[] list = new string[size];
            size_t i = 0;
            for(Item c = head; c !is null; c = c.next) {
                list[i++] = c.value;
            }
            return list;
        }
        Item front() {
            return head;
        }
        bool empty() {
            return size == 0;
        }
        unittest {
            import std.algorithm.comparison: equal;
            CDList dlist = new CDList();
            Item item2 = new Item("2");
            dlist.push(new Item("1"));
            dlist.push(item2);
            dlist.push(new Item("3"));
            //dlist.push(new Item("2"));
            //dlist.push(new Item("3"));
            assert(equal(dlist.toArray(), ["1", "2", "3"]));
            assert(dlist.length() == 3);

            dlist.remove(item2);
            assert(equal(dlist.toArray(), ["1", "3"]));
            assert(dlist.length() == 2);

            dlist.push(item2);
            assert(equal(dlist.toArray(), ["1", "3", "2"]));
            assert(dlist.length() == 3);

            Item front = dlist.front();
            assert(equal(front.value, "1"));

            dlist.remove(front);
            assert(equal(dlist.toArray(), ["3", "2"]));
            assert(dlist.length() ==  2);


            dlist.push(front);
            assert(equal(dlist.toArray(), ["3", "2", "1"]));
            assert(dlist.length() ==  3);

        }

}
