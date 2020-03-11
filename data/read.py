#!/usr/bin/env python

from bs4 import BeautifulSoup


def convert3(p):
    if p[-3:] == ".33":
        return p[:-2] + "+1.0/3"
    if p[-3:] == ".67":
        return p[:-2] + "+2.0/3"
    if p[-3:] == ".83":
        return p[:-1] + "+0.1/3"

    return p


with open("tmp.html") as f:
    text = f.read()

soup = BeautifulSoup(text, "html.parser")
table = soup.find("tbody")

floor = 0
'''
    of 1:
      result.available = {Item.Coal: 100.0}.toTable()
'''
for floor, tr in enumerate(table.find_all("tr")):
    available = "    result.available = {\n"
    total = 0
    for td in tr.find_all("td"):
        tmp = td.get_text().split()
        if len(tmp) == 3:
            item, p, _ = tmp
            total += float(p)
            p = convert3(p)
            available += "      Item.%s: %s, \n" % (item, p)
        if len(tmp) == 4:
            item0, item1, p, _ = tmp
            total += float(p)
            p = convert3(p)
            available += "      Item.%s: %s, \n" % (item0+item1, p)
    assert abs(total - 100) <= 0.1
    print("  of %d:" % (floor+1))
    print(available + "    }.toTable()")
