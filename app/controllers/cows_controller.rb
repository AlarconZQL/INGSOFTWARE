class CowsController < ApplicationController

  def create

      question_id = params[:question_id]

      answer_comment_id = params[:answer_comment_id]

      if params[:votoN_CA]=="1"
      	voto=AnswerCommentVote.new(user_id: session[:user_id],answer_comment_id: answer_comment_id,tipo: false)
        modificacionPuntuacion=-1
      end
      if params[:votoP_CA]=="1"
      	voto=AnswerCommentVote.new(user_id: session[:user_id],answer_comment_id: answer_comment_id,tipo: true)
        modificacionPuntuacion=1
      end
      if voto.save
      	flash[:message]="Voto con exito"
        usuarioPunto= User.find(AnswerComment.find(answer_comment_id).user_id)
        usuarioPunto.puntos=usuarioPunto.puntos+modificacionPuntuacion
        usuarioPunto.save
      else
      	flash[:message]="Error en el voto"
  	  end
  	  redirect_to "#{questions_path}/#{question_id}"

  end

end
