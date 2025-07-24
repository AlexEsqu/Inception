
#############################
#		VARIABLES			#
#############################

NAME	= Inception

VM		= DevVM

#############################
#		RECIPES				#
#############################

all		: $(NAME)

$(NAME)	:
		cd DevVM &&\
		./buildvm.sh &&\
		./runvm.sh

verbose	:
		./DevVM/buildvm.sh -xv
		./DevVM/runvm.sh -xv

clean	:
		./DevVM/cleanvm.sh

