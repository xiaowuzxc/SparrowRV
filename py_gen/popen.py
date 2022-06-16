import sys
import os

#python BinToMem_CLI.py ./isa/generated/rv32ui-p-add.bin inst.data
def bin_to_mem(infile, outfile):
    datafile = open(outfile, 'w')
    datafile.write(infile+'\n'+infile)
    datafile.close()


if __name__ == '__main__':
    if len(sys.argv) == 3:
        print('Usage: %s binfile datafile' % sys.argv[0], sys.argv[1], sys.argv[2])
        bin_to_mem(sys.argv[1], sys.argv[2])
    else:
        print('Usage: %s binfile datafile' % sys.argv[0], sys.argv[1], sys.argv[2])