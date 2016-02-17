function myprinteps(fig,fn)

warning off;

make_pretty(fig);
print(fig,fn,'-depsc','-r300','-painters');

warning on;
