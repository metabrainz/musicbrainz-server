/**
 * Flash-based persistent store for PersistJS.
 *
 * Compile with the following command:
 *   mtasc -swf persist.swf -header 1:1:1 -main -version 8 -strict ./PersistStore.as
 */

// import external interface namespace
import flash.external.*;

class PersistStore {
  public function PersistStore() {
  }

  public function get(name:String, key:String, val:String):String {
    var o:Object = SharedObject.getLocal(name);

    // return value
    return o.data[key];
  } 

  public function set(name:String, key:String, val:String):String {
    var o:Object = SharedObject.getLocal(name),
        old_val:String = o.data[key];

    // set new value
    o.data[key] = val;
    o.flush();

    // return old value
    return old_val;
  } 

  public function remove(name:String, key:String):String {
    var o:Object = SharedObject.getLocal(name),
        old_val:String = o.data[key];

    // clear value 
    delete o.data[key];
    o.flush();

    return old_val;
  }

  static function main() {
    var i:Number, s:Object, fns:Array = ['get', 'set', 'remove'];
  
    // create new persistent store
    s = new PersistStore();

    // add external callbacks
    for (i = 0; i < fns.length; i++)
      ExternalInterface.addCallback(fns[i], s, s[fns[i]]);
  }
};
