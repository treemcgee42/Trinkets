package store

import "core:strings"
import "core:testing"
import "core:unicode/utf8"

StoreEntry :: struct {
    ptr: rawptr,
    type: typeid,
    docstring: string,
}

LocalStore :: struct {
    items: map[string]StoreItem,
}

StoreItem :: union {
    StoreEntry,
    LocalStore,
}

make_localstore :: proc() -> LocalStore {
    return LocalStore {
        items = make(map[string]StoreItem),
    }
}

destroy_localstore :: proc(store: ^LocalStore) {
    for _name, &item in store.items {
        switch &v in item {
        case StoreEntry:
            break
        case LocalStore:
            destroy_localstore(&v)
        }
    }
    delete(store.items)
}

localstore_mkdir :: proc(ls: ^LocalStore, dirname: string) {
    _, found := ls.items[dirname]
    if found {
        return
    }
    ls.items[dirname] = make_localstore()
}

localstore_mkdir_recursive :: proc(
    ls: ^LocalStore,
    relpath: string,
) {
    dirnames := strings.split(relpath, "/")
    defer delete(dirnames)
    working_ls := ls
    for dirname in dirnames {
        found_item, exists := &working_ls.items[dirname]
        if exists {
            new_ls, ok := &found_item.(LocalStore)
            assert(ok)
            working_ls = new_ls
            continue
        }
        localstore_mkdir(working_ls, dirname)
        created_item, _ := &working_ls.items[dirname]
        working_ls = &created_item.(LocalStore)
    }
}

localstore_item_at_path :: proc(
    ls: ^LocalStore,
    path: string,
) -> (item: ^StoreItem, found: bool) {
    dirnames := strings.split(path, "/")
    defer delete(dirnames)
    found_item: ^StoreItem
    exists: bool
    working_ls := ls
    for dirname, idx in dirnames {
        found_item, exists = &working_ls.items[dirname]
        if !exists {
            found = false
            return
        }
        switch &v in found_item {
        case LocalStore:
            working_ls = &v
        case StoreEntry:
            if idx != len(dirnames) - 1 {
                found = false
                return
            }
            return found_item, true
        }
    }
    return found_item, true
}

localstore_ptr_at_path :: proc(
    ls: ^LocalStore,
    path: string,
) -> (ptr: rawptr, found: bool) {
    item, found_item := localstore_item_at_path(ls, path)
    if !found_item {
        return {}, false
    }
    entry, ok := item.(StoreEntry)
    if !ok {
        return {}, false
    }
    return entry.ptr, true
}

localstore_insert_entry :: proc(
    ls: ^LocalStore,
    path: string,
    ptr: rawptr, type: typeid,
    docstring: string,
) {
    last_slash_idx: int
    for i := len(path) - 1; i > 0; {
        codepoint, codepoint_size := utf8.decode_last_rune_in_bytes(
            transmute([]u8)path[:i])
        i -= codepoint_size
        if codepoint == '/' {
            last_slash_idx = i
            break
        }
    }
    assert(last_slash_idx > 0)

    dir_path := path[:last_slash_idx]
    dir_item, found := localstore_item_at_path(ls, dir_path)
    assert(found)
    dir_ls, ok := &dir_item.(LocalStore)
    assert(ok)

    entry_name := path[last_slash_idx + 1:]
    dir_ls.items[entry_name] = StoreEntry { ptr, type, docstring }
}

@(test)
test_localstore_mkdir :: proc(_: ^testing.T) {
    ls := make_localstore()
    defer destroy_localstore(&ls)
    localstore_mkdir(&ls, "dir1")
    localstore_mkdir(&ls, "dir2")
    _, found := ls.items["dir1"]
    assert(found)
    _, found = ls.items["dir2"]
    assert(found)
}

@(test)
test_localstore_mkdir_recursive :: proc(_: ^testing.T) {
    ls := make_localstore()
    defer destroy_localstore(&ls)
    localstore_mkdir_recursive(&ls, "dir1/dir2/dir3")
    _, found := (ls
                 .items["dir1"].(LocalStore)
                 .items["dir2"].(LocalStore)
                 .items["dir3"])
    assert(found)
    localstore_mkdir_recursive(&ls, "dir1/dir2/dir4/dir5")
    _, found = (ls
                .items["dir1"].(LocalStore)
                .items["dir2"].(LocalStore)
                .items["dir4"].(LocalStore)
                .items["dir5"].(LocalStore))
    assert(found)
        localstore_mkdir_recursive(&ls, "dir1/dir2")
    _, found = (ls
                .items["dir1"].(LocalStore)
                .items["dir2"].(LocalStore))
}

@(test)
test_localstore_item_at_path :: proc(_: ^testing.T) {
    ls := make_localstore()
    defer destroy_localstore(&ls)

    item, found := localstore_item_at_path(&ls, "dir1")
    assert(!found)

    localstore_mkdir_recursive(&ls, "dir1/dir2/dir3")
    item, found = localstore_item_at_path(&ls, "dir1/dir2/dir3")
    assert(found)
    _, ok := item.(LocalStore)
    assert(ok)

    entryA := 1
    localstore_insert_entry(&ls,
                            "dir1/entryA",
                            &entryA, typeid_of(type_of(entryA)),
                            "entryA docstring")
    item, found = localstore_item_at_path(&ls, "dir1/entryA")
    assert(found)
    entryA_entry: StoreEntry
    entryA_entry, ok = item.(StoreEntry)
    assert(ok)
    entryA_ptr := transmute(^int)entryA_entry.ptr
    assert(entryA_ptr^ == entryA)
}
