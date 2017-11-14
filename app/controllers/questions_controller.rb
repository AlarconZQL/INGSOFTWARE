class QuestionsController < ApplicationController
  def index

    if session[:user_id] != 0

        # ver si el usuario tiene seleccionado una facultad, y entonces seleccionar preguntas
        # de esa facultad

        @questions = Question.all


    else

        # iniciar preguntas

        @questions = Question.all


    end
    @faculties = Faculty.all
    @answers = Answer.all
    @labels = Label.all
    @directions = Direction.all
    @users = User.all




  end
  def show
        #Mostrar una pregunta, la de id del parametro
        @question=Question.find(params[:id])
        #Si el usuario que entra no es el que creo la pregunta el contador de visitas se actualiza+1
        if session[:user_id]!=@question.user_id
          @question.num_visitas=@question.num_visitas+1
          @question.save
        end
        @answers = Answer.all
        @users = User.all

  end

  def new
     if session[:user_id]!=0
        @labels = Label.all
  else
      redirect_to root_path
  end

  end

  def create


    etiquetas = params[:etiqueta]


    if etiquetas != nil

      if etiquetas.size >= 3 && etiquetas.size <= 5

        if params[:pregunta]!=""

          #hay que guardar la pregunta

          flash[:message] = "pregunta creada"

        else
          flash[:message] = "debe ingresar una pregunta"
        end

      else
        flash[:message] = "debe seleccionar entre 3 y 5 etiquetas"
      end

    else
      flash[:message] = "debe seleccionar entre 3 y 5 etiquetas"
    end


    render :new



  end

end
