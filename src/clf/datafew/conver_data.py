# filepath is like '/xxx/xxx/xxx/xx/'
# filename must be input.txt

def filterData(filepath):
    l = open(filepath+'data-left.txt', 'r')
    r = open(filepath+'data-right.txt', 'r')
    
    lw = open(filepath+'data-left-str.txt', 'w+')
    rw = open(filepath+'data-right-str.txt', 'w+')
    while True:
        line = l.readline()
        if line:
            lw.writelines(line[1:-3] + ',left\n')
        else:
            break
    while True:
        line = r.readline()
        if line:
            rw.writelines(line[1:-3] + ',right\n')
        else:
            break
    l.close()
    r.close()
    lw.close()
    rw.close()