class QuestionsController < ApplicationController

  def index
    $recargar=params
    @questions = filtered_questions
    @faculties = Faculty.all
    @answers = Answer.all
    @labels = Label.all
    @directions = Direction.all
    @users = User.all
    @questionvotes = QuestionVote.all

    flash[:auxIngReg] = nil #se pone en nula para que aparezca el cartel de ingresar/registrarse

  end

  def show
    #Mostrar una pregunta, la de id del parametro
    @question=Question.find(params[:id])
    #Si el usuario que entra no es el que creo la pregunta el contador de visitas se actualiza+1
    if session[:user_id]!=@question.user_id
      @question.num_visitas=@question.num_visitas+1
      @question.save
    end
    if params.has_key?(:answer_id) && @question.mejor_respuesta == nil
      @question.mejor_respuesta = params[:answer_id]
      @question.save
    end


    @answers = Answer.all
    @users = User.all
    @questionvotes = QuestionVote.all
    @questioncomments = QuestionComment.all
    @questioncommentvotes = QuestionCommentVote.all
    @answervotes = AnswerVote.all
    @answercomments = AnswerComment.all
    @answercommentvotes = AnswerCommentVote.all
    @questionlabel = QuestionLabel.all
    @labels = Label.all
    @faculties = Faculty.all
  end

  def mejor
    question_id = @question.id
    if params[:answer_id] != nil && @question.mejor_respuesta == nil
      @question.mejor_respuesta = params[:answer_id]
    end
    redirect_to "#{questions_path}/#{question_id}"
  end

  def new
     if session[:user_id]!=0
        @labels = Label.all
        @users = User.all
        @faculties =Faculty.all
        @directions=Direction.all
    else
       redirect_to root_path
    end
  end

  def create

    $recargar=params#Si llega a fallar, en $recargar, queda todos los parametros del formulario, para el rellenado
    etiquetas = params[:etiqueta]
    descripcion = params[:descripcion]

    if params[:question_id] == "0"
      if etiquetas != nil
        if etiquetas.size >= 1 && etiquetas.size <= 5
          if params[:pregunta]!=""
            pregunta=Question.new(num_visitas:0, contenido:params[:pregunta], descripcion:descripcion, user_id: session[:user_id], faculty_id: params[:facultad])
            #hay que guardar la pregunta
            if pregunta.save
               for i in (0..etiquetas.size-1)
                etiquetasPregunta=QuestionLabel.new(question_id:pregunta.id,label_id:etiquetas[i])
                if !etiquetasPregunta.save
                   break
                end
                end
                if i !=etiquetas.size-1
                  pregunta.destroy
                  flash[:message] = "Error no se creo la pregunta"
                else
               flash[:message] = "Pregunta Creada"
               $recargar=nil
             end
            else
               flash[:message] = "Error no se creo la pregunta"
            end
          else
            flash[:message] = "Debe ingresar una pregunta"
          end
        else
          flash[:message] = "Debe seleccionar entre 1 y 5 etiquetas"
        end
      else
        flash[:message] = "Debe seleccionar entre 1 y 5 etiquetas"
      end
      if flash[:message] != "Pregunta Creada"
        redirect_to new_question_path
      else
        redirect_to root_path
      end
    else
      update
    end

  end

  def filtered_questions
    result = Question.all
    user_id = session[:user_id]
    if user_id > 0
      fac_id = User.find(user_id).faculty_id  # obtengo el id de facultd del usuario
      if fac_id != 0
        result = result.where(faculty_id: fac_id) # si se tiene una facultad elegida filtro por esa facultad
      end
    end

    if params.has_key?(:facultad) # Si se clickeo el boton Buscar
      if params[:facultad] != "0" # Si la facultad elegida no es todas
                  if params.has_key?(:busqueda)# Si ingreso algo a buscar, dentro de una facultad
                    result = Question.all.where("contenido ILIKE ? OR descripcion ILIKE ?","%#{params[:busqueda]}%","%#{params[:busqueda]}%") # si se esta buscando algo se filtra en base a eso
                    result=result.where(faculty_id: params[:facultad])
                   else # Mostrar todas las preguntas de una facultad
                    result = Question.all.where(faculty_id: params[:facultad])
                  end
      else
                  if params.has_key?(:busqueda)# Si ingreso algo a buscar, en todas las facultades
                    result = Question.all.where("contenido ILIKE ? OR descripcion ILIKE ?","%#{params[:busqueda]}%","%#{params[:busqueda]}%") # si se esta buscando algo se filtra en base a eso
                   else # Muestro todas las preguntas
                    result = Question.all
                  end
      end

      if params[:etiqueta]!="0" # Si la etiqueta elegida no es todas
        #preguntasEtiqueta=QuestionLabel.joins("INNER JOIN labels ON labels.id = question_labels.label_id AND labels.id=1")
        #El JOIN queda identico que la linea de abajo
        preguntasEtiqueta=QuestionLabel.all.where(label_id: params[:etiqueta])
        arregloPreguntasid=preguntasEtiqueta.select(:question_id)
        result=result.where(id:arregloPreguntasid)
      else #Si es todas, dejo la busqueda como esta
        result=result
      end

    end

    if result.count == 0
      flash[:message] = "No se han encontrado resultados para su busqueda"
    end
    result.order(created_at: :desc) # se ordenan las preguntas a mostrar por fecha de creacion de mas reciente a mas antigua
  end

  def edit
    @user = User.find(session[:user_id])
    @question = Question.find(params[:id])
    @labels = Label.all
    @faculties = Faculty.all
    @directions = Direction.all
    @question_labels = QuestionLabel.all
  end

  def update
    $recargar=params#Si llega a fallar, en $recargar, queda todos los parametros del formulario, para el rellenado
    etiquetas = params[:etiqueta]
    descripcion = params[:descripcion]
    @user = User.find(session[:user_id])
    @question = Question.all.where(user_id: session[:user_id]).first

    if etiquetas != nil
      if etiquetas.size >= 1 && etiquetas.size <= 5
        if params[:pregunta]!=""
          pregunta=Question.new(num_visitas:0, contenido:params[:pregunta], descripcion:descripcion, user_id: session[:user_id], faculty_id: params[:facultad])
          #hay que guardar la pregunta
          if pregunta.save
             for i in (0..etiquetas.size-1)
              etiquetasPregunta=QuestionLabel.new(question_id:pregunta.id,label_id:etiquetas[i])
              if !etiquetasPregunta.save
                 break
              end
              end
              if i !=etiquetas.size-1
                pregunta.destroy
                flash[:message] = "Error no se modifico la pregunta"
              else
             flash[:message] = "Pregunta Modificada"
             $recargar=nil
           end
          else
             flash[:message] = "Error no se modifico la pregunta"
          end
        else
          flash[:message] = "Debe ingresar una pregunta"
        end
      else
        flash[:message] = "Debe seleccionar entre 1 y 5 etiquetas"
      end
    else
      flash[:message] = "Debe seleccionar entre 1 y 5 etiquetas"
    end

    if flash[:message] != "Pregunta Modificada"
      redirect_to "/questions/#{@question.id}/edit"
    else
      @question.contenido = pregunta.contenido
      @question.descripcion = pregunta.descripcion
      @question.faculty_id = pregunta.faculty_id
      QuestionLabel.where(question_id: @question.id).each do |l|
        l.destroy
      end
      QuestionLabel.where(question_id: pregunta.id).each do |l|
        l.question_id = @question.id
        l.save
      end
      @question.save
      pregunta.destroy
      redirect_to root_path
    end
  end
end
