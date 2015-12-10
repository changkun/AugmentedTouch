# filepath is like '/xxx/xxx/xxx/xx/'
# filename must be input.txt
def filterData(filepath, left=1):
    f = open(filepath+'input.txt', 'r')
    o = open(filepath+'output.txt', 'w+')
    while True:
        line = f.readline()
        if line:
            result = line.split(' ')[3]
            if left == 1:
                o.writelines(result[1:len(result)-2] + ',left\n')
            else:
                o.writelines(result[1:len(result)-2] + ',right\n')
        else:
            break
    f.close()
    o.close()