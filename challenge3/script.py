def nested_function(obj, key):
    keys = key.split('/')
    for k in keys:
        if k in obj:
            obj = obj[k]
        else:
            return None
    return obj
object = {"a":{"b":{"c":"d"}}}
key = "a/b/c"

values = nested_function(object, key)
print(values)