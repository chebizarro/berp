// ==++==
// 
//   Copyright (c) Microsoft Corporation.  All rights reserved.
// 
// ==--==
/*============================================================
**
** Interface:  KeyValuePair
** 
** <OWNER>[....]</OWNER>
**
**
** Purpose: Generic key-value pair for dictionary enumerators.
**
** 
===========================================================*/
namespace System.Collections.Generic {
    

    // A KeyValuePair holds a key and a value from a dictionary.
    // It is used by the IEnumerable<T> implementation for both IDictionary<TKey, TValue>
    // and IReadOnlyDictionary<TKey, TValue>.
	//[Compact]
    public class KeyValuePair<TKey, TValue> {
        private TKey key;
        private TValue value;

        public KeyValuePair(TKey key, TValue value) {
            this.key = key;
            this.value = value;
        }

        public TKey Key {
            get { return key; }
        }

        public TValue Value {
            get { return value; }
        }

        public string ToString (GLib.StringBuilder s) {
            /*
            s.append('[');
            if( Key != null) {
                s.append(Key.ToString());
            }
            s.append(", ");
            if( Value != null) {
               s.append(Value.ToString());
            }
            s.append(']');
            */
            return s.str;
        }
    }
}
