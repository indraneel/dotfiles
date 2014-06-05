LNFLAGS = -fsn
RMFLAGS = -f

all: config 

config:
	ln $(LNFLAGS) $(PWD)/bash_profile $(HOME)/.bash_profile
	ln $(LNFLAGS) $(PWD)/bashrc $(HOME)/.bashrc
	ln $(LNFLAGS) $(PWD)/bash_aliases $(HOME)/.bash_aliases
	ln $(LNFLAGS) $(PWD)/vim $(HOME)/.vim
	ln $(LNFLAGS) $(PWD)/vimrc $(HOME)/.vimrc

clean:
	rm $(RMFLAGS) $(HOME)/.bash_aliases
	rm $(RMFLAGS) $(HOME)/.bash_profile
	rm $(RMFLAGS) $(HOME)/.bash_prompt
	rm $(RMFLAGS) $(HOME)/.bashrc
	rm $(RMFLAGS) $(HOME)/.vim
	rm $(RMFLAGS) $(HOME)/.vimrc
